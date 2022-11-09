// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IMsysERC20 is IERC20Upgradeable {
    function _mintEx(address account, uint256 amount,address caller) external;
    function _transferEx(address from,address to, uint256 amount,address caller) external;
    function transferEx(address account, uint256 amount,address caller) external;
    function _burnEx(address account, uint256 amount,address caller) external;
}

contract LotteryContract is Initializable, UUPSUpgradeable, OwnableUpgradeable{
    // token = MyToken's contract address\
    function initialize(address token) public initializer {
        _token = IMsysERC20(token);
        admin=msg.sender;
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
    
    struct User{
        uint id;
        address walletAddress;
        string name;
        string email;
        bool disabled;
    }
    struct lotteryWinner{
        address first;
        address second;
        address third;
    }
    struct Lottery{
        uint lotteryId;
        string lotteryName;
        uint amount;
        uint statusCode;
        uint date;
    }
    struct Participant{
        address participantAddress;
        uint selectedTeam;
        uint amount;
    }

    IMsysERC20 _token;
    User[] public users;
    Lottery[] public lotteries;
    uint[] public lotteryAmountArray;
    address public admin;
    mapping(address => User) public userList;
    mapping(uint => address[]) public lotteryParticipants;
    mapping(uint => lotteryWinner) public lotteryWinners;

    event log(string message, address account, address admin);

    // ===================================MODIFIERS================================================

    modifier validLottery(uint lotteryId){
    require(lotteryId < lotteries.length,"Invalid lotteryId");
    require(lotteries[lotteryId].statusCode==2,"Lottery is not active");
    _;
    }
    modifier validUser(){
    require(userList[msg.sender].walletAddress==msg.sender,"Only Registered Users can Participate");
    require(userList[msg.sender].disabled==false,"Disabled Users can't Participate");
    _;
    }

    // ===================================USER=====================================================
    
    function addUser(address walletAddress,string memory name,string memory email) public onlyOwner{
        emit log("event on addUser", msg.sender, admin);
        require(walletAddress!=admin,"Admin cannot be a User");
        require(userList[walletAddress].walletAddress != walletAddress,"User already exist");
        userList[walletAddress]=User(users.length,walletAddress,name,email,false);
        users.push(User(users.length,walletAddress,name,email,false));
        _token._mintEx(walletAddress, 5000,msg.sender);
    }

    function getUsersLength() public view returns (uint) {
        return users.length;
    }

    function disableUser(address userAddress) public onlyOwner {
        users[userList[userAddress].id].disabled=true;
        userList[userAddress].disabled=true;
    }

    function enableUser(address userAddress) public onlyOwner {
        users[userList[userAddress].id].disabled=false;
        userList[userAddress].disabled=false;
    }

    // ===================================Lottery================================================

    function addLottery(string memory lotteryName, uint amount, uint timeStamp) public onlyOwner {
        _token._mintEx(address(this), 1000, msg.sender);
        lotteries.push(Lottery(lotteries.length, lotteryName, amount, 1, timeStamp));
        lotteryAmountArray.push(0);
    }

    function getLotteriesLength() public view returns(uint){
        return lotteries.length;
    }
    
    function getAllLotteries() public view returns (Lottery[] memory) {
        return lotteries;
    }

    function getLotteryAmountArray() public view returns (uint[] memory array) {
       return lotteryAmountArray;
    }

    function updateLotteryStatus(uint lotteryId, uint statusCode) public onlyOwner {
        lotteries[lotteryId].statusCode=statusCode;
    }

    function participateLottery(uint lotteryId) public validUser validLottery(lotteryId) returns(bool success){
        for (uint i=0; i<users.length; i++) {
            if(users[i].walletAddress == msg.sender){
                uint lotteryAmount=lotteries[lotteryId].amount;
                uint feesAmount=lotteryAmount/100;
                uint finalLotteryAmount=lotteryAmount-feesAmount;
                _token.transferEx(address(this), finalLotteryAmount,msg.sender);
                _token._burnEx(msg.sender, feesAmount,msg.sender);
                lotteryParticipants[lotteryId].push(msg.sender);
                return true;
            }
        } 
        return false;
    }

    function getLotteryParticipantsLength(uint lotteryId) public view returns(uint){
        return lotteryParticipants[lotteryId].length;
    }

    function getLotteryParticipants(uint lotteryId) public view returns (address[] memory) {
        return lotteryParticipants[lotteryId];
    }

    // -------------------Lottery-Result------------------

    function randomNumber(uint number) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, number)));
    }

    function announceLotteryResult(uint lotteryId) public onlyOwner validLottery(lotteryId){
        require(lotteryParticipants[lotteryId].length >= 5,"Minimum 5 participants required");
        uint participantsLength=lotteryParticipants[lotteryId].length;
        uint lotteryAmount=lotteries[lotteryId].amount;
        uint totalAmount=(participantsLength*((lotteryAmount/100)*99))+1000;
        uint randomNumber0=randomNumber(12);
        uint randomNumber1=randomNumber(123);
        uint randomNumber2=randomNumber(1234);
        uint index0=  randomNumber0 % participantsLength;
        uint index1;
        uint index2;
        do{
            randomNumber1++;
            index1= randomNumber1 % participantsLength;
        }while(index0==index1); 
        do{
            randomNumber2++;
            index2= randomNumber2 % participantsLength;
        }while(index0==index2 || index1==index2);

        //-------------------Save Winners Addresses------------------------

        lotteryWinners[lotteryId]=lotteryWinner(lotteryParticipants[lotteryId][index0],lotteryParticipants[lotteryId][index1],lotteryParticipants[lotteryId][index2]);

        //-------------------Transfer Amount------------------------
        
            _token._transferEx(address(this), lotteryParticipants[lotteryId][index0], ((totalAmount/100)*50),msg.sender);
            _token._transferEx(address(this), lotteryParticipants[lotteryId][index1], ((totalAmount/100)*30),msg.sender);
            _token._transferEx(address(this), lotteryParticipants[lotteryId][index2], ((totalAmount/100)*20),msg.sender);

        lotteries[lotteryId].statusCode=3;
        lotteryAmountArray[lotteryId]=totalAmount;
    }

}