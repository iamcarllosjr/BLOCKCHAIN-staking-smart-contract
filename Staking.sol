// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract staking is IERC721Receiver, ERC721Holder {

    IERC20 public TokenReward; 
    using SafeERC20 for IERC20; 
    IERC721 public NFTItem;

    mapping(address => mapping(uint256 => uint256)) public stakes;
    mapping(address => uint256) public lastStakeTime;
    mapping(address => uint256) public stakingAmount;

    //Constructor receives nft token address and reward token address
    constructor (address _reward, address _nft) {
        TokenReward = IERC20(_reward); 
        NFTItem = IERC721(_nft);
    }
    
    event Stake(address indexed owner, uint256 id, uint256 time); 
    event UnStake(address indexed owner, uint256 id, uint256 time, uint256 rewardTokens); 
    
    function stakeNFT(uint256 _tokenId) public  {

        require(NFTItem.ownerOf(_tokenId) == msg.sender, "You do not own this token");

        NFTItem.safeTransferFrom(msg.sender, address(this), _tokenId);

        stakes[msg.sender][_tokenId] = block.timestamp;

        emit Stake (msg.sender, _tokenId, block.timestamp);
    }

    function unStake (uint256 _tokenId) public {

       uint256 reward = calculateReward(_tokenId);

       delete stakes[msg.sender][_tokenId];

       NFTItem.safeTransferFrom(address(this), msg.sender, _tokenId, "");
       
       TokenReward.transfer(msg.sender, reward);
    }

    function calculateReward (uint256 _tokenId) public view returns (uint256) {

        require(stakes[msg.sender][_tokenId] > 0, "NFT has not been staked");

        uint256 timeElapsed = block.timestamp - stakes[msg.sender][_tokenId];

        uint256 reward = timeElapsed * (10 ** 18) / 1 days;

        return reward;
    }

}