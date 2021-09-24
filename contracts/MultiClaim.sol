pragma solidity ^0.8.6;

//"SPDX-License-Identifier: None

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface Iclaimable {
    // Views
    function claimable(uint _summoner) external view returns(uint);
    // Calls
    function claim(uint _summoner) external;
}

interface Icellar{
    //Views
    function adventurers_log(uint) external view returns(uint);
    function scout(uint) external view returns(uint);

    //Calls
    function adventure(uint) external;
}

contract MultiClaimer is UUPSUpgradeable, OwnableUpgradeable{

    //Proxy Stuff

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function initialize() public initializer {
        //constructor
        __Ownable_init();     

    }

    function checkMulticlaim(address claimAddress, uint[] calldata ids) public view returns(uint[] memory){
        uint[] memory resArr=new uint[](ids.length);
        for(uint i=0;i<ids.length;i++){
            resArr[i]=Iclaimable(claimAddress).claimable(ids[i])>0?ids[i]:0;
        }
        return resArr;
    }
    function multiclaim(address claimAddress, uint[] calldata ids) external {
        for(uint i=0;i<ids.length;i++)
        try Iclaimable(claimAddress).claim(ids[i]){

        }catch{

        }
    }

    function multiScout(address cellarAddress, uint[] calldata ids) public view returns (uint[] memory){
        uint[] memory resArr=new uint[](ids.length);
        for(uint i=0;i<ids.length;i++){
            resArr[i]=Icellar(cellarAddress).scout(ids[i])>0?ids[i]:0;
        }
        return resArr;
    }

    function multiCellar(address cellarAddress, uint[] calldata ids) external {
        for(uint i=0;i<ids.length;i++){
            try Icellar(cellarAddress).adventure(ids[i]){

            }catch{

            }
        }
    }
}