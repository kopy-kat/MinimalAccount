// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "account-abstraction/core/EntryPoint.sol";
import "solady/utils/ECDSA.sol";

struct Owner {
    address addr;
    uint256 key;
}

contract MinimalAccountTest is Test {
    MinimalAccount public minimalAccount;
    MinimalAccountFactory public minimalAccountFactory;

    address entrypointAddress = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    EntryPoint public entryPoint = new EntryPoint();

    Owner owner;

    function setUp() public {
        owner = Owner({key: uint256(1), addr: vm.addr(uint256(1))});
        minimalAccount = MinimalAccount(HuffDeployer.deploy("MinimalAccount"));
        minimalAccountFactory = MinimalAccountFactory(HuffDeployer.deploy("MinimalAccountFactory"));

        // Get bytecode of MinimalAccount and MinimalAccountFactory for gas calculations
        // console.logBytes(address(minimalAccount).code);
        // console.logBytes(address(minimalAccountFactory).code);
    }

    function testCreateAccount() public {
        address account = minimalAccountFactory.createAccount(address(this), 0);
        assertEq(address(minimalAccount).code, address(account).code);
    }

    function testGetAccountAddress() public {
        address account = minimalAccountFactory.createAccount(address(this), 0);
        address accountAddress = minimalAccountFactory.getAddress(address(this), 0);
        assertEq(account, accountAddress);
    }

    function testValidateUserOp() public {
        vm.startPrank(entrypointAddress);
        vm.deal(address(minimalAccount), 1 ether);
        UserOperation memory userOp = UserOperation({
            sender: minimalAccountFactory.getAddress(address(this), 0),
            nonce: 0,
            initCode: abi.encodePacked(
                address(minimalAccountFactory),
                abi.encodeWithSelector(minimalAccountFactory.createAccount.selector, address(this), 0)
                ),
            callData: abi.encodeWithSelector(minimalAccount.execute.selector, address(this), 0, ""),
            callGasLimit: 0,
            verificationGasLimit: 0,
            preVerificationGas: 0,
            maxFeePerGas: 0,
            maxPriorityFeePerGas: 0,
            paymasterAndData: "",
            signature: ""
        });

        bytes32 opHash = entryPoint.getUserOpHash(userOp);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner.key, ECDSA.toEthSignedMessageHash(opHash));
        bytes memory signature = abi.encodePacked(r, s, v);
        userOp.signature = signature;

        uint256 missingAccountFunds = 420 wei;
        uint256 returnValue = minimalAccount.validateUserOp(userOp, opHash, missingAccountFunds);
        assertEq(returnValue, 0);
        assertEq(entrypointAddress.balance, missingAccountFunds);
        vm.stopPrank();
    }

    function testValidateUserOp__RervertWhen__NotFromEntrypoint() public {
        vm.startPrank(address(0x69));
        vm.deal(address(minimalAccount), 1 ether);
        UserOperation memory userOp = UserOperation({
            sender: address(this),
            nonce: 0,
            initCode: abi.encodePacked(
                address(minimalAccountFactory),
                abi.encodeWithSelector(minimalAccountFactory.createAccount.selector, address(this), 0)
                ),
            callData: abi.encodeWithSelector(minimalAccount.execute.selector, address(this), 0, ""),
            callGasLimit: 0,
            verificationGasLimit: 0,
            preVerificationGas: 0,
            maxFeePerGas: 0,
            maxPriorityFeePerGas: 0,
            paymasterAndData: "",
            signature: ""
        });
        uint256 missingAccountFunds = 420 wei;
        vm.expectRevert();
        uint256 returnValue = minimalAccount.validateUserOp(userOp, "", missingAccountFunds);
        vm.stopPrank();
    }

    function testExecuteValue() public {
        vm.startPrank(entrypointAddress);
        vm.deal(address(minimalAccount), 2 wei);
        minimalAccount.execute(address(0x69), 1 wei, "");
        assertEq(address(0x69).balance, 1 wei);
        assertEq(address(minimalAccount).balance, 1 wei);
        vm.stopPrank();
    }

    function testExecuteCalldata() public {
        vm.startPrank(entrypointAddress);
        minimalAccount.execute(
            address(0x69),
            0,
            abi.encodeWithSignature("transfer(address,address,uint256)", address(0x123456), address(0xdeadbeef), 69)
        );
        vm.stopPrank();
    }

    function testExecute__RevertWhen__NotFromEntrypoint() public {
        vm.startPrank(address(0x69));
        vm.expectRevert();
        minimalAccount.execute(
            address(0x69),
            0,
            abi.encodeWithSignature("transfer(address,address,uint256)", address(0x123456), address(0xdeadbeef), 69)
        );
        vm.stopPrank();
    }
}

interface MinimalAccount {
    function execute(address to, uint256 value, bytes calldata data) external;
    function validateUserOp(UserOperation calldata, bytes32, uint256) external returns (uint256);
}

interface MinimalAccountFactory {
    function createAccount(address owner, uint256 salt) external returns (address);
    function getAddress(address owner, uint256 salt) external view returns (address);
}
