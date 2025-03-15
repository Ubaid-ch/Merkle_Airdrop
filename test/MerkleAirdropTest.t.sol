// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test,console } from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker,Test{
    MerkleAirdrop public airdrop;
    BagelToken public token;
    bytes32 Root=0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address public gasPayer;
    address user;
    uint256 privateKey;
    uint256 AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 AMOUNT_TO_AIRDROP= AMOUNT_TO_CLAIM * 4;
    bytes32 proof1=0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2=0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proof1,proof2];

    function setUp() public {
        if(!isZkSyncChain()){
             DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        }else{
        token = new BagelToken();
        airdrop = new MerkleAirdrop(Root ,token);
        token.mint(token.owner(),AMOUNT_TO_AIRDROP);
        token.transfer(address(airdrop),AMOUNT_TO_AIRDROP);
        }
        (user,privateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");

    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest= airdrop.getMessage(user, AMOUNT_TO_CLAIM);

        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v , r , s);   

        uint256 endingBalance = token.balanceOf(user);

        assertEq(endingBalance-startingBalance,AMOUNT_TO_CLAIM);     
        
    }

}