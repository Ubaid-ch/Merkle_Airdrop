// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MerkleAirdrop is EIP712 {

    using SafeERC20 for IERC20; // Prevent sending tokens to recipients who can’t receive
    
    ///////////
    //errors//
    ////////// 
    error MerkleAirdrop__InvalidProof(address account, uint256 amount);
    error MerkleAirdrop__AlreadyClaimed(address account, uint256 amount);
    error MerkleAirdrop__invalidSignature();

    address[] claimers; // list of addresses that can claim tokens
    bytes32 private immutable i_merkleRoot; // the merkle root of the merkle tree
    IERC20 private immutable i_airDropToken; // the token to be airdropped
    mapping ( address claimer => bool claimed) s_hasClaimed; // mapping of addresses that have claimed tokens
    bytes32 private constant MESSAGE_TYPEHASH= keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    ///////////
    ///events//
    //////////
    event Claimed(address account, uint256 amount);


    constructor(bytes32 merkleRoot, IERC20 airDropToken) EIP712("MerkleAirdrop","1")  {
        // store the merkle roots
        i_merkleRoot = merkleRoot;
        // store the token
        i_airDropToken = airDropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        if(s_hasClaimed[account]){
            // if the account has already claimed tokens, revert
            revert MerkleAirdrop__AlreadyClaimed(account,amount);
        }

        // verify the signature
        if(!_isValidSignature(account, getMessage(account, amount), v, r, s)){
            revert MerkleAirdrop__invalidSignature();
        }
        // Verify the merkle proof
        // calculate the leaf node hash
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        // verify the merkle proof
        if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)){
            // if the proof is invalid, revert
            revert MerkleAirdrop__InvalidProof(account,amount);
        }
        s_hasClaimed[account] = true;
        emit Claimed(account, amount);
        // transfer the tokens
        i_airDropToken.safeTransfer(account, amount);
    }

    function getMessage(address account, uint256 amount) public view returns(bytes32){
            return _hashTypedDataV4(
                keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount:amount})))
            );
    }

    function _isValidSignature(address account,bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns(bool){
        (address actualSigner, , ) = ECDSA.tryRecover(digest,v ,r ,s);
        return actualSigner == account;
    }


}