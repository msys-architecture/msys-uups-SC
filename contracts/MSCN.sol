// SPDX-License-Identifier: MIT
// Author: Sanjay Singh
pragma solidity >= 0.5.0 < 0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


contract MsysERC20 is Initializable, ERC20Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    function initialize() public initializer {
        __ERC20_init("MsysCoin", "MSCN");
        _mint(msg.sender, 10000);
        __Ownable_init();
        __UUPSUpgradeable_init();
        admin=msg.sender;
    }

    address public admin;

    event log(string message, address account, address admin);

    function _authorizeUpgrade(address) internal override onlyOwner {}
    
    function _mintEx(address userAccount, uint256 amount,address caller) external {
        emit log("event on _mintEx", msg.sender, admin);
        require(admin == caller,"only owner can call this");
        _mint(userAccount, amount);
    }

    function _transferEx(address from,address to, uint256 amount,address caller) external {
        emit log("event on _transferEx", msg.sender, admin);
        require(admin == caller,"only owner can call this");
        _transfer(from, to, amount);
    }

    function transferEx(address to, uint256 amount,address caller) external {
        emit log("event on transferEx", msg.sender, admin);
        require(admin == caller,"only owner can call this");
        transfer(to, amount);
    }

    function _burnEx(address account, uint256 amount,address caller) external {
        emit log("event on _burnEx", msg.sender, admin);
        require(admin == caller,"only owner can call this");
       _burn(account, amount);
    }

    function decimals() override public pure returns (uint8) {
        return 0;
    }
        

    function getBalanceOfSM() public view returns(uint){
        return balanceOf(address(this));
    }

}