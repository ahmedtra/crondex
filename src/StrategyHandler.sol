// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IReaperVault} from "./interfaces/IReaperVault.sol";
import "./interfaces/IStrategy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console2} from "forge-std/console2.sol";
import {IXReceiver} from "@connext/interfaces/core/IXReceiver.sol";

import {IConnext} from "@connext/interfaces/core/IConnext.sol";

/**
 * @dev Implementation of a vault to deposit funds for yield optimizing.
 * This is the contract that receives funds and that users interface with.
 * The yield optimizing strategy itself is implemented in a separate 'Strategy.sol' contract.
 */
contract StrategyHandler is IXReceiver, Ownable {
    using SafeERC20 for IERC20;

    // The strategy in use by the vault.
    IReaperVault public reaperVault;
    IERC20 public token;
    address public sourceVault;
    IConnext public connext;
    uint32 public destinationDomain;
    uint256 public slippage = 10000;

    /**
     * @dev Initializes the  Reaper strategy handler
     * @param _reaperVault reaper vault on optimism.
     * @param _token the sender contract.
     */
    constructor(address _reaperVault, address _token, address _connext, uint32 _destinationDomain)
        Ownable(msg.sender)
    {
        reaperVault = IReaperVault(_reaperVault);
        token = IERC20(_token);
        connext = IConnext(_connext);
        destinationDomain = _destinationDomain;
    }

    receive() external payable {}

    function initSource(address _sourceVault) external {
        sourceVault = _sourceVault;
    }

    function withdraw(uint256 amount, uint256 relayerFee, address signer) public {
        require(relayerFee != 0, "please provide relayer fee");
        require(amount != 0, "please provide amount");
        // uint256 _pool = totalAmount(); //TDDO: error here check tomorow
        // uint256 amount_to_withdraw = amount * _pool / 100;

        // require(_pool - amount >= 0, "not enough funds");

        // reaperVault.withdraw(amount_to_withdraw, address(this), address(reaperVault));
        // uint256 actualShares = reaperVault.convertToShares(amount);
        uint256 actualShares = amount;
        console2.log("actual shares", actualShares);
        console2.log("shares ", reaperVault.balanceOf(address(this)));
        reaperVault.withdraw(actualShares, address(this), address(this));

        console2.log("withdraw Success fuck this");
        uint256 _amount = token.balanceOf(address(this));
        if (_amount < amount) {
            console2.log("token is lesss", _amount);
            revert("Bal is less than requested");
        }
        _xSendCompoundedTokens(relayerFee, _amount, signer);
    }

    function totalAmount() public view returns (uint256) {
        return reaperVault.balanceOf(address(this));
    }

    event amountReceived(uint256 _amount);

    function xReceive(
        bytes32, /*_transferId*/
        uint256 _amount,
        address _asset,
        address, /*_originSender*/
        uint32, /*_origin*/
        bytes memory _callData
    ) external returns (bytes memory) {
        (bool deposit, address signer, uint256 amount, uint256 relayerfee) =
            abi.decode(_callData, (bool, address, uint256, uint256));

        if (deposit) {
            require(_asset == address(token), "Wrong asset received");
            require(_amount > 0, "Must pay at least 1 wei");
            console2.log(address(reaperVault));
            token.approve(address(reaperVault), _amount);
            // reaperVault.deposit(address(token), _amount);
            console2.log("amount", _amount);
            reaperVault.deposit(_amount);
            emit amountReceived(_amount);
        } else {
            withdraw(amount, relayerfee, signer);
        }
    }

    function getTokenBal() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function _xSendCompoundedTokens(uint256 relayerFee, uint256 amount, address signer) internal {
        bytes memory callData = abi.encode(signer);
        token.approve(address(connext), amount);
        connext.xcall{value: relayerFee}(
            destinationDomain, // _destination: Domain ID of the destination chain
            sourceVault, // _to: address of the target contract
            address(token), // _asset: address of the token contract
            msg.sender, // _delegate: address that can revert or forceLocal on destination
            amount, // _amount: amount of tokens to transfer
            slippage, // _slippage: max slippage the user will accept in BPS (e.g. 300 = 3%)
            callData // _callData: the encoded calldata to send
        );
    }
}
