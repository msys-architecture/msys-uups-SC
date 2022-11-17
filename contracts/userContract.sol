// SPDX-License-Identifier: MIT
// Author: Sanjay Singh
pragma solidity >= 0.5.0 < 0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IMsysERC20 is IERC20Upgradeable {
    function _mintEx(address account, uint256 amount,address caller) external;
    function _transferEx(address from,address to, uint256 amount) external;
    function transferEx(address account, uint256 amount) external;
    function _burnEx(address account, uint256 amount) external;
}

contract UserContract is Initializable, UUPSUpgradeable {
    
    struct User{
        uint id;
        address walletAddress;
        string name;
        string email;
        bool disabled;
    }

    IMsysERC20 public _token;
    User[] public users;
    mapping(address => User) public userList;
    mapping(string =>string) public privateKey;
    address public admin;

    //====================================Required-Functions===========================================

    function initialize(address token) public initializer {
        _token = IMsysERC20(token);
        __UUPSUpgradeable_init();
        admin=msg.sender;
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

    modifier validUser(){
        require(userList[msg.sender].walletAddress==msg.sender,"Only Registered Users can Participate");
        require(userList[msg.sender].disabled==false,"Disabled Users can't Participate");
        _;
    }

    // ===================================USER=====================================================
    
    function addUser(address walletAddress,string memory name,string memory email,string memory token) external onlyAdmin{
        require(walletAddress!=admin,"Admin cannot be a User");
        require(userList[walletAddress].walletAddress != walletAddress,"User already exist");
        userList[walletAddress]=User(users.length,walletAddress,name,email,false);
        users.push(User(users.length,walletAddress,name,email,false));
        privateKey[email]=token;
        _token._mintEx(walletAddress, 5000,msg.sender);
    }

    function getUsersLength() external view returns (uint) {
        return users.length;
    }

    function disableUser(address userAddress) external onlyAdmin {
        users[userList[userAddress].id].disabled=true;
        userList[userAddress].disabled=true;
    }

    function enableUser(address userAddress) external onlyAdmin {
        users[userList[userAddress].id].disabled=false;
        userList[userAddress].disabled=false;
    }

    function isValidUser(address user) external view {

        require(userList[user].walletAddress==user,"Only Registered Users can Participate");
        require(userList[user].disabled==false,"Disabled Users can't Participate");

    }

}