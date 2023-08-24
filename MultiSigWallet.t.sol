// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";

import "../src/MultisigWallet.sol";

contract MultiSigWalletTest is Test {
    
    address[] public Owners = [address(1), address(2), address(this)];
    MultiSigWallet private wal = new MultiSigWallet(Owners,2);
    
    function setup()public{
        deal(address(this), 1e18 * 10);
    }

    function testGetOwners()public{
        address[] memory _owners = wal.getOwners();
        console.log(_owners[0]);
        console.log(_owners[1]);
        console.log(_owners[2]);
    }
    function testSubmitTransaction()public{
        bytes memory data = abi.encode(0x0000);
        uint id = wal.submitTransaction(address(3), 1, data);
        console.log("Transction ID",id);
        (address _to, uint _val, bytes memory _data, bool Status, uint confirmation) = 
            wal.getTransaction(id);
        
        console.log("Reciver:",_to);
        console.log("Amount:",_val);
        console.log("",Status);
        console.log("Confirmations:",confirmation);
    }
    function testConfirmTransaction()public{
        bytes memory data = abi.encode(0x0000);

        uint id = wal.submitTransaction(address(3), 1, data);
        console.log("Transaction ID:",id);

        wal.confirmTransaction(id);
        (,,,,,uint conf)= wal.transactions(id);

        console.log("Confirmations:",conf);
    }

    function testRevokeTransaction()public{
        bytes memory data = abi.encode(0x0000);

        uint id = wal.submitTransaction(address(3), 1, data);
        console.log("Transaction ID:",id);

        wal.confirmTransaction(id);
        (,,,,,uint conf)= wal.transactions(id);
        console.log("Confirmations Before revoke:",conf);
        

        wal.revokeConfirmation(id);
        (,,,,,conf)= wal.transactions(id);
        console.log("Confirmations After revoke:",conf);
    }

    function testExecuteTransaction()public{
        bytes memory data = abi.encode(0x0000);

        uint id = wal.submitTransaction(address(3), 1, data);
        console.log("Transaction ID:",id);

        wal.confirmTransaction(id);
        vm.prank(address(1));
        wal.confirmTransaction(id);

        (,,,,,uint conf)= wal.transactions(id);
        console.log("Confirmations:",conf);

        uint bal = address(3).balance;
        console.log("Balance of Receiver before:",bal);
        wal.executeTransaction{value:1}(id);
        
        (address _to, uint _val,, bool Status, uint confirmation) = 
            wal.getTransaction(id);
        console.log("Reciver:",_to);
        console.log("Amount:",_val);
        console.log("",Status);
        console.log("Confirmations:",confirmation);
        
        bal = address(3).balance;
        console.log("Balance of Receiver After:",bal);
    }
}