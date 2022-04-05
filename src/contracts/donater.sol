// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Donater{
    struct Donate{
        address payable owner;
        string title;
        string  description;
        string  image;
        uint goal;
        uint amountDonated;
        // bool goalReached;
    }


    // mapping(uint256=>Donate) internal donations;
    Donate[] donations; // array of Donate type
    uint256 donateLength = 0;

    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address internal adminAddress = 0xE2a0411465fd913502A8390Fe22DC7004AC47A04;

    event donated(address indexed sender, uint256 amount);
    event addedDonation(address indexed owner, string title, uint256 index);
    event donationClosed(address indexed owner, string title, uint256 totalAmount, uint256 index);

    function addDonation(
        string memory _title,
        string memory _description,
        string memory _image,
        uint _goal 
    )public payable{
        require(
             IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                adminAddress,
                1e18
            ),
            "Transaction could not be performed"
        );
        donations.push(Donate(
            payable(msg.sender),
            _title,
            _description,
            _image,
            _goal,
            0
            // false
        ));
        emit addedDonation(msg.sender, _title, donateLength);
        donateLength++;
    }

    function getDonation(uint _index)public view returns(
        address payable,
        string memory,
        string memory,
        string memory,
        uint,
        uint
        // bool
    ){
        Donate storage _donations = donations[_index];
        return(
            _donations.owner,
            _donations.title,
            _donations.description,
            _donations.image,
            _donations.goal,
            _donations.amountDonated
            // _donations.goalReached
        );
    }

    function donate(uint _index, uint amount)public payable {
        require(donations[_index].amountDonated < donations[_index].goal, "Not accepting any more donations. Thank you!");
        require(
             IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                donations[_index].owner,
                amount
            ),
            "Transaction could not be performed"
        );
        emit donated(msg.sender, amount);
        donations[_index].amountDonated+=amount;
        if(donations[_index].amountDonated >= donations[_index].goal){
            // donations[_index].goalReached = true; // we don't actually require this, it is pretty clear that if amountDonated >= goal then close the donation
            // as we are also not using the goalReached value anywhere. So it is kindoff redundant
            emit donationClosed(donations[_index].owner, donations[_index].title, donations[_index].amountDonated, _index);

            // if you want to remove the donation post, as it has reached its goal
            removeDonationPost(_index); // this will remove the donation post from the array.
        }
    }

    function getDonationLength() public view returns (uint){
        return donateLength;
    }

    function removeDonationPost(uint _index) public {
        donations[_index] = donations[donations.length - 1];
        donations.pop();
    }
}