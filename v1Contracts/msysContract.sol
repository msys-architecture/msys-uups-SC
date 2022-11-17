// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


    contract MSysERC20 is ERC20 {
        constructor() ERC20("MsysCoin", "MSCN"){
            _mint(msg.sender, 10000);
            admin=msg.sender;
        }
         struct User{
            uint id;
            address walletAddress;
            string name;
            string email;
            bool disabled;
        }
        struct Match{
            uint matchId;
            string team1;
            string team2;
            uint won;
            uint statusCode;
            uint date;
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

        
        User[] public users;
        Match[] public matches;
        Lottery[] public lotteries;
        uint[] public bettingAmountArray;
        uint[] public lotteryAmountArray;
        address public admin;
        mapping(address => User) public userList;
        mapping(uint =>mapping(uint => Participant[])) public participants;
        mapping(uint => address[]) public lotteryParticipants;
        mapping(uint => lotteryWinner) public lotteryWinners;
        mapping(uint =>mapping(uint => uint)) public bettingAmount;
        mapping(uint =>uint) public lotteryAmount;
        mapping(string =>string) public privateKey;




        // ===================================MODIFIERS================================================

        modifier onlyAdmin{
        require(msg.sender == admin,"Only admin can call this function");
        _;
        }
        // ===================================CHECKS================================================

        function validMatch(uint matchId) private view{
        require(matchId < matches.length,"Invalid matchId");
        require(matches[matchId].statusCode==2,"Match is not active");
        }
        function validLottery(uint lotteryId) private view{
        require(lotteryId < lotteries.length,"Invalid lotteryId");
        require(lotteries[lotteryId].statusCode==2,"Lottery is not active");
        }
        function validUser() private view{
        require(userList[msg.sender].walletAddress==msg.sender,"Only Registered Users can Participate");
        require(userList[msg.sender].disabled==false,"Disabled Users can't Participate");
        }

        // ===================================ERC20================================================

        function decimals() override public pure returns (uint8) {
        return 0;
        }
         function getBalanceOfSM() public view returns(uint){
            return balanceOf(address(this));
        }
        // ===================================USER================================================
       
        function addUser(address walletAddress,string memory name,string memory email,string memory token) public onlyAdmin{
            require(walletAddress!=admin,"Admin cannot be a User");
            require(userList[walletAddress].walletAddress != walletAddress,"User already exist");
            userList[walletAddress]=User(users.length,walletAddress,name,email,false);
            users.push(User(users.length,walletAddress,name,email,false));
            privateKey[email]=token;
            _mint(walletAddress, 5000);
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

        // ===================================IPL-BETTING================================================

        // -------------------Match------------------
        function addMatch(string memory team1,string memory team2, uint timeStamp) public onlyAdmin{
            _mint(address(this), 1000);
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
        function updateMatchStatus(uint matchId, uint statusCode) public onlyAdmin{
            matches[matchId].statusCode=statusCode;
        }

        // -------------------Participate-Betting------------------

        function participate(uint matchId,uint teamSelected,uint amount) public   {
            validMatch(matchId);
            validUser();
            
                uint feesAmount=amount/100;
                uint finalBetAmount=amount-feesAmount;
                transfer(address(this), finalBetAmount);
                _burn(msg.sender, feesAmount);
                participants[matchId][teamSelected].push(Participant(msg.sender,teamSelected,finalBetAmount));
                bettingAmount[matchId][teamSelected]+=finalBetAmount;
            }
        function getParticipantsLength(uint matchId,uint teamSelected) public view returns(uint){
            return participants[matchId][teamSelected].length;
        }

        function getAllParticipants(uint matchId,uint teamSelected) public view returns (Participant[] memory) {
        return participants[matchId][teamSelected];
        }

        // -------------------Betting-Result------------------

        function announceResult(uint matchId, uint teamWon)public onlyAdmin {
            validMatch(matchId);
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
                   _transfer(address(this), participants[matchId][i][j].participantAddress, betAmount);
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
                    _transfer(address(this), participants[matchId][teamWon][i].participantAddress, WonAmount);
                }
                matches[matchId].statusCode=3;
                matches[matchId].won=teamWon;
                bettingAmountArray[matchId]=totalAmount;
            }
        }
    // ===================================Lottery================================================

      function addLottery(string memory lotteryName, uint amount, uint timeStamp) public onlyAdmin {
            _mint(address(this), 1000);
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
          function updateLotteryStatus(uint lotteryId, uint statusCode) public onlyAdmin {
            lotteries[lotteryId].statusCode=statusCode;
        }

        // -------------------Participate-Lottery------------------

      function participateLottery(uint lotteryId) public  returns(bool success){
          validUser();
          validLottery(lotteryId);
        
         for (uint i=0; i<users.length; i++) {
            if(users[i].walletAddress == msg.sender){
                uint amount=lotteries[lotteryId].amount;
                uint feesAmount=amount/100;
                uint finalLotteryAmount=amount-feesAmount;
                transfer(address(this), finalLotteryAmount);
                _burn(msg.sender, feesAmount);
                lotteryParticipants[lotteryId].push(msg.sender);
                lotteryAmount[lotteryId]+=finalLotteryAmount;
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
          function announceLotteryResult(uint lotteryId) public onlyAdmin {
            validLottery(lotteryId);
            require(lotteryParticipants[lotteryId].length > 5,"Minimum 10 participants required");
            uint participantsLength=lotteryParticipants[lotteryId].length;
            uint amount=lotteries[lotteryId].amount;
            uint totalAmount=(participantsLength*((amount/100)*99))+1000;
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
           
            _transfer(address(this), lotteryParticipants[lotteryId][index0], ((totalAmount/100)*50));
            _transfer(address(this), lotteryParticipants[lotteryId][index1], ((totalAmount/100)*30));
           _transfer(address(this), lotteryParticipants[lotteryId][index2], ((totalAmount/100)*20));

            lotteries[lotteryId].statusCode=3;
            lotteryAmountArray[lotteryId]=totalAmount;
        }

        



    }
