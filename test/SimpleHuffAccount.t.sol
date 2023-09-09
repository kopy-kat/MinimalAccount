// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "account-abstraction/contracts/core/EntryPoint.sol";
import "solady/utils/ECDSA.sol";

struct UserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;
    bytes callData;
    uint256 callGasLimit;
    uint256 verificationGasLimit;
    uint256 preVerificationGas;
    uint256 maxFeePerGas;
    uint256 maxPriorityFeePerGas;
    bytes paymasterAndData;
    bytes signature;
}

contract SimpleHuffAccountTest is Test {
    /// @dev Address of the SimpleStore contract.
    SimpleHuffAccount public simpleHuffAccount;
    SimpleHuffAccountFactory public simpleHuffAccountFactory;

    address entrypointAddress = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    EntryPoint public entryPoint = EntryPoint(entrypointAddress);

    /// @dev Setup the testing environment.
    function setUp() public {
        simpleHuffAccount = SimpleHuffAccount(HuffDeployer.deploy("SimpleHuffAccount"));
        simpleHuffAccountFactory = SimpleHuffAccountFactory(HuffDeployer.deploy("SimpleHuffAccountFactory"));
        console.logBytes(address(simpleHuffAccount).code);
        console.logBytes(address(simpleHuffAccountFactory).code);
    }

    function testCreateAccount() public {
        address account = simpleHuffAccountFactory.createAccount(address(this), 0);
        assertEq(address(simpleHuffAccount).code, address(account).code);
    }

    function testGetAccountAddress() public {
        address account = simpleHuffAccountFactory.createAccount(address(this), 0);
        address accountAddress = simpleHuffAccountFactory.getAddress(address(this), 0);
        assertEq(account, accountAddress);
    }

    function testValidateUserOp() public {
        vm.startPrank(entrypointAddress);
        vm.deal(address(simpleHuffAccount), 1 ether);
        UserOperation memory userOp = UserOperation({
            sender: address(this),
            nonce: 0,
            initCode: abi.encodePacked(
                address(simpleHuffAccountFactory),
                abi.encodeWithSelector(simpleHuffAccountFactory.createAccount.selector, address(this), 0)
                ),
            callData: abi.encodeWithSelector(simpleHuffAccount.execute.selector, address(this), 0, ""),
            callGasLimit: 0,
            verificationGasLimit: 0,
            preVerificationGas: 0,
            maxFeePerGas: 0,
            maxPriorityFeePerGas: 0,
            paymasterAndData: "",
            signature: ""
        });
        bytes32 hash = entryPoint.getUserOpHash(_op);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_key, ECDSA.toEthSignedMessageHash(hash));
        signature = abi.encodePacked(r, s, v);
        uint256 missingAccountFunds = 420 wei;
        uint256 returnValue = simpleHuffAccount.validateUserOp(userOp, "", missingAccountFunds);
        assertEq(returnValue, 0);
        assertEq(entrypointAddress.balance, missingAccountFunds);
        vm.stopPrank();
    }

    function testValidateUserOp__RervertWhen__NotFromEntrypoint() public {
        vm.startPrank(address(0x69));
        vm.deal(address(simpleHuffAccount), 1 ether);
        UserOperation memory userOp = UserOperation({
            sender: address(this),
            nonce: 0,
            initCode: abi.encodePacked(
                address(simpleHuffAccountFactory),
                abi.encodeWithSelector(simpleHuffAccountFactory.createAccount.selector, address(this), 0)
                ),
            callData: abi.encodeWithSelector(simpleHuffAccount.execute.selector, address(this), 0, ""),
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
        uint256 returnValue = simpleHuffAccount.validateUserOp(userOp, "", missingAccountFunds);
        vm.stopPrank();
    }

    function testExecuteValue() public {
        vm.startPrank(entrypointAddress);
        vm.deal(address(simpleHuffAccount), 2 wei);
        simpleHuffAccount.execute(address(0x69), 1 wei, "");
        assertEq(address(0x69).balance, 1 wei);
        assertEq(address(simpleHuffAccount).balance, 1 wei);
        vm.stopPrank();
    }

    function testExecuteCalldata() public {
        vm.startPrank(entrypointAddress);
        simpleHuffAccount.execute(
            address(0x69),
            0,
            abi.encodeWithSignature("transfer(address,address,uint256)", address(0x123456), address(0xdeadbeef), 69)
        );
        vm.stopPrank();
    }

    function testExecute__RevertWhen__NotFromEntrypoint() public {
        vm.startPrank(address(0x69));
        vm.expectRevert();
        simpleHuffAccount.execute(
            address(0x69),
            0,
            abi.encodeWithSignature("transfer(address,address,uint256)", address(0x123456), address(0xdeadbeef), 69)
        );
        vm.stopPrank();
    }
}

interface SimpleHuffAccount {
    function execute(address to, uint256 value, bytes calldata data) external;
    function validateUserOp(UserOperation calldata, bytes32, uint256) external returns (uint256);
}

interface SimpleHuffAccountFactory {
    function createAccount(address owner, uint256 salt) external returns (address);
    function getAddress(address owner, uint256 salt) external view returns (address);
}
