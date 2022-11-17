// SPDX-License-Identifier: MIT
// Author: Sanjay Singh
pragma solidity >= 0.5.0 < 0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IMsysERC20 is IERC20Upgradeable {
    function _mintEx(address account, uint256 amount,address caller) external;
    function _transferEx(address from,address to, uint256 amount) external;
    function transferEx(address account, uint256 amount) external;
    function _burnEx(address account, uint256 amount) external;
}

interface IUsersContract {
    function isValidUser(address user) external;
}

contract BettingContractV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {

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
    IUsersContract public _userCont;

    //====================================Required-Functions===========================================
    
    // _token = MsysToken's contract address
    // _userCont = MsysToken's contract address
    function upgradeV2(address tokenAddress, address userContAddress) external onlyAdmin {
        _token = IMsysERC20(tokenAddress);
        _userCont = IUsersContract(userContAddress);
    }

    function _authorizeUpgrade(address) internal override onlyAdmin {}

    function transferAdminship(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }

    // ===================================MODIFIERS================================================

    modifier onlyAdmin{
        require(msg.sender == admin,"Only admin can call this function");
        _;
    }

    modifier validMatch(uint matchId){
        require(matchId < matches.length,"Invalid matchId");
        require(matches[matchId].statusCode==2,"Match is not active");
        _;
    }

    // -------------------Match------------------
    function addMatch(string memory team1,string memory team2, uint timeStamp) external onlyAdmin{
        _token._mintEx(address(this), 1000, msg.sender);
        matches.push(Match(matches.length,team1,team2,0,1,timeStamp));
        bettingAmountArray.push(0);
    }
    function getMatchesLength() external view returns(uint){
        return matches.length;
    }
    function getAllMatches() external view returns (Match[] memory) {
        return matches;
    }
    function getBettingAmountArray() external view returns (uint[] memory) {
        return bettingAmountArray;
    }
    function updateMatchStatus(uint matchId, uint statusCode) public onlyAdmin{
        matches[matchId].statusCode=statusCode;
    }

    // -------------------Participate-Betting------------------

    function participate(uint matchId,uint teamSelected,uint amount) public validMatch(matchId) {
        _userCont.isValidUser(msg.sender);
        uint feesAmount=amount/100;
        uint finalBetAmount=amount-feesAmount;
        _token.transferEx(address(this), finalBetAmount);
        _token._burnEx(msg.sender, feesAmount);
        participants[matchId][teamSelected].push(Participant(msg.sender,teamSelected,finalBetAmount));

    }
    function getParticipantsLength(uint matchId,uint teamSelected) public view returns(uint){
        return participants[matchId][teamSelected].length;
    }

    function getAllParticipants(uint matchId,uint teamSelected) public view returns (Participant[] memory) {
        return participants[matchId][teamSelected];
    }

    // -------------------Betting-Result------------------

    function announceResult(uint matchId, uint teamWon)public onlyAdmin validMatch(matchId){
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