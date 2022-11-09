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

contract BettingContract is Initializable, UUPSUpgradeable, OwnableUpgradeable {

    function initialize(address token) public initializer {
        _token = IMsysERC20(token);
        admin=msg.sender;
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    struct Match{
        uint matchId;
        string team1;
        string team2;
        uint won;
        uint statusCode;
        uint date;
    }
    struct Participant{
        address participantAddress;
        uint selectedTeam;
        uint amount;
    }
    struct User{
        uint id;
        address walletAddress;
        string name;
        string email;
        bool disabled;
    }
    IMsysERC20 public _token;
    Match[] public matches;
    User[] public users;
    uint[] public bettingAmountArray;
    mapping(address => User) public userList;
    mapping(uint =>mapping(uint => Participant[])) public participants;
    address public admin;

    // ===================================MODIFIERS================================================

    modifier validMatch(uint matchId){
        require(matchId < matches.length,"Invalid matchId");
        require(matches[matchId].statusCode==2,"Match is not active");
        _;
    }
    modifier validUser(){
        require(userList[msg.sender].walletAddress==msg.sender,"Only Registered Users can Participate");
        require(userList[msg.sender].disabled==false,"Disabled Users can't Participate");
        _;
    }

    // ===================================USER=====================================================
    
    function addUser(address walletAddress,string memory name,string memory email) public onlyAdmin{
        require(walletAddress!=admin,"Admin cannot be a User");
        require(userList[walletAddress].walletAddress != walletAddress,"User already exist");
        userList[walletAddress]=User(users.length,walletAddress,name,email,false);
        users.push(User(users.length,walletAddress,name,email,false));
        _token._mintEx(walletAddress, 5000,msg.sender);
    }

    function getUsersLength() public view returns (uint) {
        return users.length;
    }

    function disableUser(address userAddress) public onlyAdmin {
        users[userList[userAddress].id].disabled=true;
        userList[userAddress].disabled=true;
    }

    function enableUser(address userAddress) public onlyAdmin {
        users[userList[userAddress].id].disabled=false;
        userList[userAddress].disabled=false;
    }

    // -------------------Match------------------
    function addMatch(string memory team1,string memory team2, uint timeStamp) public onlyOwner{
        // _mint(address(this), 1000);
        matches.push(Match(matches.length,team1,team2,0,1,timeStamp));
        bettingAmountArray.push(0);
    }
    function getMatchesLength() public view returns(uint){
        return matches.length;
    }
    function getAllMatches() public view returns (Match[] memory) {
    return matches;
    }
    function getBettingAmountArray() public view returns (uint[] memory) {
    return bettingAmountArray;
    }
    function updateMatchStatus(uint matchId, uint statusCode) public onlyOwner{
        matches[matchId].statusCode=statusCode;
    }

    // -------------------Participate-Betting------------------

    function participate(uint matchId,uint teamSelected,uint amount) public validUser validMatch(matchId) {
        
        uint feesAmount=amount/100;
        uint finalBetAmount=amount-feesAmount;
        _token.transferEx(address(this), finalLotteryAmount,msg.sender);
        _token._burnEx(msg.sender, feesAmount,msg.sender);
        participants[matchId][teamSelected].push(Participant(msg.sender,teamSelected,finalBetAmount));

    }
    function getParticipantsLength(uint matchId,uint teamSelected) public view returns(uint){
        return participants[matchId][teamSelected].length;
    }

    function getAllParticipants(uint matchId,uint teamSelected) public view returns (Participant[] memory) {
    return participants[matchId][teamSelected];
    }

    // -------------------Betting-Result------------------

    function announceResult(uint matchId, uint teamWon)public onlyOwner validMatch(matchId){
        require(teamWon==1 || teamWon==2 || teamWon==3,"Wrong Input");
        uint totalAmount=1000;
        uint teamWonTotalAmount=0;
            for(uint i=1;i<3 ;i++){
                for(uint j=0;j<participants[matchId][i].length;j++){
                totalAmount += participants[matchId][i][j].amount;
            }
        }
        if(teamWon==3){
        for(uint i=1;i<3 ;i++){
                for(uint j=0;j<participants[matchId][i].length;j++){
                uint betAmount= (participants[matchId][i][j].amount*100)/99;
                _token._transferEx(address(this), participants[matchId][i][j].participantAddress, betAmount);
                bettingAmountArray[matchId]=totalAmount;
            }
        }
        matches[matchId].statusCode=3;
        }else{
        for(uint i=0;i<participants[matchId][teamWon].length;i++){
                teamWonTotalAmount += participants[matchId][teamWon][i].amount;
            }
        for(uint i=0;i<participants[matchId][teamWon].length;i++){
                uint betAmount= participants[matchId][teamWon][i].amount;
                uint WonAmount=totalAmount*betAmount/teamWonTotalAmount;
                _token._transferEx(address(this), participants[matchId][teamWon][i].participantAddress, WonAmount);
            }
            matches[matchId].statusCode=3;
            matches[matchId].won=teamWon;
            bettingAmountArray[matchId]=totalAmount;
        }
    }



}