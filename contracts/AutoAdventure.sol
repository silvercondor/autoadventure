pragma solidity ^0.8.6;

//"SPDX-License-Identifier: None

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface Irarity{
    // Views
    function ownerOf(uint) external view returns(address);
    function next_summoner() external view returns(uint);
    function adventurers_log(uint) external view returns(uint);
    function balanceOf(address) external view returns(uint);
    function xp(uint) external view returns(uint);
    function xp_required(uint) external view returns(uint);    
    function level(uint) external view returns(uint);
    
    //Calls
    function adventure(uint) external;
    function level_up(uint) external;
    function summon(uint) external;
    function safeTransferFrom(address, address, uint) external;
}

interface Icellar{
    //Views
    function adventurers_log(uint) external view returns(uint);
    function scout(uint) external view returns(uint);

    //Calls
    function adventure(uint) external;
}

interface Igold{
    //Views
    function claimable(uint) external view returns(uint);

    //Calls
    function claim(uint) external;
}

contract AutoAdventure is OwnableUpgradeable, UUPSUpgradeable {
        
    mapping(address=>uint[]) public addressToCharacterMap;
    
    //Proxy stuff
    Irarity rarity;
    
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function initialize() public initializer {
        //constructor
        __Ownable_init();
        rarity = Irarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    

    }

    //gas saving
    bytes32 constant onERC721ReceivedResponse = keccak256("onERC721Received(address,address,uint256,bytes)");
    
    function getCharacters(address user, uint start, uint end) public view returns(uint[] memory){
        uint userChars = rarity.balanceOf(user);
        uint counter;
        uint[] memory charArr = new uint[](userChars);
        for(uint i=start; i <= end; i++){
            if(rarity.ownerOf(i)==user){
                charArr[counter]=i;
                counter++;
            }
            if(i==rarity.next_summoner()){
                break;
            }
        }
        return charArr;
    }

    function viewUserTokens(address user) external view returns(uint[] memory){
        return addressToCharacterMap[user];
    }
    
    function batchCheckTime(uint[] calldata ids) external view returns(bool[] memory){
        uint currentTime=block.timestamp;
        bool[] memory logArr=new bool[](ids.length);
        for(uint i=0;i<ids.length;i++){
            rarity.adventurers_log(ids[i]) + 1 days > currentTime?logArr[i]=true:logArr[i]=false;
        }
        return logArr;
    }
    
        
    function addTokens(uint[] calldata ids) external{
        for(uint i=0; i<ids.length; i++){
            addressToCharacterMap[msg.sender].push(ids[i]);
        }
    }
    
    function removeToken(uint tokenId) external {
        //expensive to call, do consider removing everything and re-adding
        for(uint i=0; i<addressToCharacterMap[msg.sender].length; i++){
            //finds tokenId to remove
            if(addressToCharacterMap[msg.sender][i]==tokenId){
                //replace pop element with last array element
                addressToCharacterMap[msg.sender][i]=addressToCharacterMap[msg.sender][addressToCharacterMap[msg.sender].length-1];
                //reduce array length
                addressToCharacterMap[msg.sender].pop();
            }
        }
        
    }
    
    function removeAllTokens() external{
        delete addressToCharacterMap[msg.sender];
    }
    
    function _adventure(uint charId) internal{
            //normal adventure
            try rarity.adventure(charId){

            }catch{

            }
            //cellar adventure
            //if (Icellar(0x2A0F1cB17680161cF255348dDFDeE94ea8Ca196A).scout(charId)>0){
                //adventure if scout success
                //Icellar(0x2A0F1cB17680161cF255348dDFDeE94ea8Ca196A).adventure(charId);
        // }
    }

    function startAdventure(uint[] calldata ids) external{
        //Note: from a UI perspective it is more efficient to read the ids and call this function
        for(uint i=0; i<ids.length; i++){            
            _adventure(ids[i]);
        }
    }
    
    function savedCharsAdventure() external{
        uint[] memory ids=addressToCharacterMap[msg.sender];
        for(uint i=0; i<ids.length;i++){
            //normal adventure
            _adventure(ids[i]);        
        }
    }

    function savedCharsLvlUp() external{
        //try catch used as reading the xp required is very costly and should be done offchain
        uint[] memory ids=addressToCharacterMap[msg.sender];
        for (uint i=0; i<ids.length;i++){
            try rarity.level_up(ids[i]){
                
            }catch{

            }            

        }
    }

    function savedCharsClaimGold() external{
        //requires approve for each summoner on rarity contract
        //try catch used as claimable function goes thru the same checks as claim
        //hence it is more efficient to attempt to claim directly
        uint[] memory ids=addressToCharacterMap[msg.sender];
        for (uint i=0; i<ids.length; i++){
            try Igold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2).claim(ids[i]){

            }catch{

            }
        }
    }

    function batchCheckLvlUp(address userAddress) public view returns(uint[] memory){
        //try to avoid calling in transaction
        uint[] memory ids = addressToCharacterMap[userAddress];
        uint[] memory resArr = new uint[](ids.length);
        for (uint i=0;i<ids.length;i++){
            resArr[i]=(rarity.xp(ids[i]) >= rarity.xp_required(rarity.level(ids[i]))?ids[i]:0);
        }
        return resArr;
    }    

    function batchLvlUp(uint[] calldata ids) external{
        for (uint i=0;i<ids.length;i++){
            try rarity.level_up(ids[i]){
                
            }catch{

            }
        }
    }

    function batchCheckClaimGold(address userAddress) public view returns(uint[] memory){
        //try to avoid calling in transaction
        uint[] memory ids = addressToCharacterMap[userAddress];
        uint[] memory resArr = new uint[](ids.length);
        for (uint i=0;i<ids.length;i++){
            resArr[i]=Igold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2).claimable(ids[i])>0?ids[i]:0;
        }
        return resArr;
    }

    function batchClaimGold(uint [] calldata ids) external{
        //requires approve on rarity contract for each summoner id
        //claiming is expensive
        for(uint i=0; i<ids.length;i++){
            try Igold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2).claim(ids[i]){

            }catch{

            }
        }
    }
    

    function batchTransfer(uint[] calldata ids, address to) external{
        for(uint i=0; i<ids.length; i++){
            rarity.safeTransferFrom(msg.sender, to, ids[i]);
        }
    }

    function summonOne(uint charType) external{
        uint tokenId=rarity.next_summoner();
        rarity.summon(charType);
        addressToCharacterMap[msg.sender].push(tokenId);
        rarity.safeTransferFrom(address(this), msg.sender, tokenId);
    }
    
    function summonAll() external{
        uint tokenId=rarity.next_summoner();
        for(uint i=1;i<=11;i++){
            rarity.summon(i);
            addressToCharacterMap[msg.sender].push(tokenId);
            rarity.safeTransferFrom(address(this), msg.sender, tokenId);
            tokenId++;
        }
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external view returns (bytes4) {
        return bytes4(onERC721ReceivedResponse);
    }
}
	