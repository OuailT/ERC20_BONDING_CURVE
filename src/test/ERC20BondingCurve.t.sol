
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../ERC20BondingCurve.sol";


contract TestBondedToken is Test {


    event MintTokens(address indexed Minter, uint256 amountToMint);
    event BurnedTokens(address indexed Burner, uint256 _amountToBurn, uint256 payBackAmount);

    ERC20BondingCurve ERCBondingCurveContract;
    USDT USDTTokenContract;
    address public User1;
    address public User2;
    address public whale;

    uint256 public reserveRatio = 500000; // 50% RR = Linear Bonding Curve.


    function setUp() public {
        USDTTokenContract = new USDT();

        ERCBondingCurveContract = new ERC20BondingCurve(
            reserveRatio,
            address(USDTTokenContract)
        );

        User1 = vm.addr(0x1234);
        User2 = vm.addr(0x5678);
        whale = vm.addr(0x43290);

        vm.label(User1, "USER1");
        vm.label(User2, "USER2");
        vm.label(whale, "Whale");

        USDTTokenContract.transfer(User1, 50 ether);
        USDTTokenContract.transfer(User2, 200 ether);
        USDTTokenContract.transfer(whale, 70000 ether);

    }

    // Call the function that calculate the the mintamount based on the deposit after minting
    // The amount returned by that function should be equal to amount of BTC token received by the user.
    function testMintingTokensSuccessfully() public {
        
    console.log("----------------------------INITIAL VALUES TO DETERMINE THE PRICE------------------------------------------");
        console.log("Initial totalSupply of BTC tokens ", ERCBondingCurveContract.totalSupply());
        console.log("Initial Contract reserve in USDT ", ERCBondingCurveContract.reserveBalance());
        console.log("Initial reserve ratio", ERCBondingCurveContract.reserveRatio());
        console.log("Initial price tokens of BTC", ERCBondingCurveContract.getBTCPrice());

        emit log_named_decimal_uint("Address(this) Balance in BTC",
                                    IERC20(ERCBondingCurveContract).balanceOf(address(this))
                                    , 18);
        
        emit log_named_decimal_uint("Address(this) Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(this))
                                    , 18);

        emit log_named_decimal_uint("User2 Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(User2)), 18);

        
        vm.startPrank(User1);

        console.log("-------------------------User1-----------------------------");

        emit log_named_decimal_uint("User1 Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(User1)),
                                     18);

        emit log_named_decimal_uint("User1 Balance in BTC before ",
                                    IERC20(ERCBondingCurveContract).balanceOf(address(User1))
                                    , 18);
        
        emit log_named_decimal_uint("Current BTC price before user1 mint ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 0);

        USDTTokenContract.approve(address(ERCBondingCurveContract), 50 ether);

        uint256 user1ExpMintReturn = ERCBondingCurveContract.calculateContinuousMintReturn(50 ether);

        ERCBondingCurveContract.mint(50 ether);

        uint256 use1BTCBalance = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
        uint256 user1USDTBalance = USDTTokenContract.balanceOf(address(User1));
        uint256 poolBalAfterUser1Mint = IERC20(USDTTokenContract).balanceOf(address(ERCBondingCurveContract));

        emit log_named_decimal_uint("Current BTC price after user1 mint ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 0);

        emit log_named_decimal_uint("User1 Balance in USDT after minting BTC", user1USDTBalance, 18);
        emit log_named_decimal_uint("User1 Balance in BTC after", use1BTCBalance , 18);

        // Check if User1's BTC balance matches the expected mint return
        assertEq(use1BTCBalance , user1ExpMintReturn, " User1 BTC balance incorrect");

        // Check if User1's USDT balance is zero after minting
        assertEq(user1USDTBalance, 0, "User1 USDT balance should be zero");

        // Check if the bonding curve contract reserve balance increased correctly after User1's deposit
        assertEq(poolBalAfterUser1Mint, 50 ether, "Reserve should increase by 50 USDT after User1 deposit");

        console.log("------------------------------------------------------");

        vm.stopPrank();



        vm.startPrank(User2);

        console.log("-------------------------User2-----------------------------");

        emit log_named_decimal_uint("User2 Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(User2)),
                                     18);

        emit log_named_decimal_uint("User2 Balance in BTC before ",
                                    IERC20(ERCBondingCurveContract).balanceOf(address(User2))
                                    , 18);
        
        emit log_named_decimal_uint("Current BTC price before user2 mint ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    ,18 );

        USDTTokenContract.approve(address(ERCBondingCurveContract), 200 ether);

        uint256 user2ExpMintReturn = ERCBondingCurveContract.calculateContinuousMintReturn(200 ether);

        ERCBondingCurveContract.mint(200 ether);

        uint256 use2BTCBalance = IERC20(ERCBondingCurveContract).balanceOf(address(User2));
        uint256 user2USDTBalance = USDTTokenContract.balanceOf(address(User2));
        uint256 poolBalAfterUser2Mint = IERC20(USDTTokenContract).balanceOf(address(ERCBondingCurveContract));

        emit log_named_decimal_uint("Current BTC price after user2 mint ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);

        // How do I know The currentPrice of the token;
        emit log_named_decimal_uint("User2 Balance in USDT after minting BTC",
                                    user2USDTBalance , 18);

        emit log_named_decimal_uint("User2 Balance in BTC after",
                                    use2BTCBalance, 18);
        
        emit log_named_decimal_uint("User2 Balance in BTC after",
                                    use2BTCBalance, 18);
    
        // Check if User1's BTC balance matches the expected mint return
        assertEq(use2BTCBalance , user2ExpMintReturn, " User2 BTC balance incorrect");

        // Check if User2's USDT balance is zero after minting
        assertEq(user2USDTBalance, 0, "User2 USDT balance should be zero");

        // Check if the bonding curve contract reserve balance increased correctly after User2's deposit
        assertEq(poolBalAfterUser2Mint, 250 ether, "Reserve should increase by 50 USDT after User2 deposit");

        console.log("--------------------------------------------------------------------------");

        emit log_named_decimal_uint("Bonding curve contract Reserve/Pool/Balance ",
                                    poolBalAfterUser2Mint,
                                    18);

        vm.stopPrank();
       
    }


    // stopped at test emit event
    function testMintEventEmitted() public {
        vm.startPrank(User1);
        uint amountToMint = ERCBondingCurveContract.calculateContinuousMintReturn(50 ether);
        USDTTokenContract.approve(address(ERCBondingCurveContract), 50 ether);
        vm.expectEmit(true, false, false, true);
        emit MintTokens(address(User1), amountToMint); 
        ERCBondingCurveContract.mint(50 ether);
    }


    // stopped at test emit event
    function testBurnEventEmitted() public {
        testMintingTokensSuccessfully();
        vm.startPrank(User2);
        uint256 amountToBurn = IERC20(ERCBondingCurveContract).balanceOf(address(User2));
        uint256 payBackAmount = ERCBondingCurveContract.calculateContinuousBurnReturn(amountToBurn);
        vm.expectEmit(true, false, false, true);
        emit BurnedTokens(address(User2), amountToBurn, payBackAmount); 
        ERCBondingCurveContract.burn(amountToBurn);
    }


    function testExpectRevertNotEnoughAllowance() public {
        vm.startPrank(User1);
            USDTTokenContract.transfer(User1, 50 ether);
            USDTTokenContract.approve(address(ERCBondingCurveContract), 40 ether);
            vm.expectRevert("NOT_ENOUGH_ALLOWANCE");
            ERCBondingCurveContract.mint(50 ether);
        vm.stopPrank();
    }

    function testExpectRevertMintZeroAmount() public {
        vm.startPrank(User1);
            USDTTokenContract.transfer(User1, 50 ether);
            USDTTokenContract.approve(address(ERCBondingCurveContract), 50 ether);
            vm.expectRevert("DEPOSIT_AMOUNT_ZERO");
            ERCBondingCurveContract.mint(0);
        vm.stopPrank();
    }


    // Specify what exactly this function is testing in the Natspec    
    function testBurningTokensSuccessfully() public {
        testMintingTokensSuccessfully();

        console.log("----------------------------The Burrrn User1----------------------------------------------");

        vm.startPrank(User1);

        uint256 use1BTCBalancebef = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
        uint256 user1ExpBurnReturn = ERCBondingCurveContract.calculateContinuousBurnReturn(use1BTCBalancebef);

        console.log("user1ExpBurnReturn",user1ExpBurnReturn);

        emit log_named_decimal_uint("User1 Balance in USDT before Burning BTC", USDTTokenContract.balanceOf(address(User1)), 18);

        ERCBondingCurveContract.burn(use1BTCBalancebef);

        uint256 use1BTCBalanceAft = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
        uint256 user1USDTBalance = USDTTokenContract.balanceOf(address(User1));
        uint256 poolBalAfterUser1Burn = IERC20(USDTTokenContract).balanceOf(address(ERCBondingCurveContract));
        
        emit log_named_decimal_uint("User1 Balance in USDT after Burning BTC",
                                     user1USDTBalance, 18);
        emit log_named_decimal_uint("User1 Balance in BTC after",
                                     use1BTCBalanceAft , 18);
        emit log_named_decimal_uint("Bonding curve contract Reserve/Pool/Balance",
                                     poolBalAfterUser1Burn , 18);
        
        // Check if User1's BTC balance is is zero after Burning all his BTC balance
        assertEq(use1BTCBalanceAft , 0, " User1 BTC balance Should be zero after burn");

        // // Check if User1's USDT balance match the expected burn return
        assertEq(user1USDTBalance, user1ExpBurnReturn, "User2 USDT balance Incorrect");

        // // Check if the bonding curve contract reserve balance decreased correctly after User2'1 Burn/Withdraw
        assertEq(poolBalAfterUser1Burn, 250 ether - user1ExpBurnReturn, "Reserve should decrease by expect burn return after User2 Burn");
        
        console.log("---------------------------------------------------------------------------------");

        vm.stopPrank();

    }


    function testExpectRevertNotEnoughTokensToBurn() public {
        testMintingTokensSuccessfully();
        vm.startPrank(User1);
             uint256 use1BalBTCToBurn = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
            vm.expectRevert("INSUFFICIENT_BURN_BALANCE");
            ERCBondingCurveContract.burn(use1BalBTCToBurn + 1);
        vm.stopPrank();
    }


    function testExpectRevertBurnZeroAmount() public {
        vm.startPrank(User1);
            vm.expectRevert("AMOUNT_ZERO");
            ERCBondingCurveContract.burn(0);
        vm.stopPrank();
    }

    // Test that the price of tokens decreases after several burns
    function testPriceIncreaseAfterWhalePurchase() public  {
        testMintingTokensSuccessfully();
        // Get the current price of BTC Tokens after User1 and User2
        
        vm.startPrank(whale);
        emit log_named_decimal_uint("User1 Balance in BTC before ",
                                    IERC20(ERCBondingCurveContract).balanceOf(address(whale))
                                    , 18);
                                    
        emit log_named_decimal_uint("Current BTC price before whale Purchase",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);
        
        USDTTokenContract.approve(address(ERCBondingCurveContract), 70000 ether);

        // uint256 whaleExpMintReturn = ERCBondingCurveContract.calculateContinuousMintReturn(70000 ether);
        uint256 initialPrice = ERCBondingCurveContract.getBTCPrice();

        ERCBondingCurveContract.mint(70000 ether);

        emit log_named_decimal_uint("Current BTC price After whale Purchase",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);
        uint256 expectedIncreasedPricePercentage = 90;
        uint256 expectedIncreasePrice = initialPrice * (100 + expectedIncreasedPricePercentage) / 100;
        uint256 newPrice = ERCBondingCurveContract.getBTCPrice();

        vm.stopPrank();

        // Check that User1 and User2 tokens value increased if they want to burn/sell after whale purchase
        vm.startPrank(User1);
        uint256 user1AmountToBurn = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
        uint256 user1PayBackAmount = ERCBondingCurveContract.calculateContinuousBurnReturn(user1AmountToBurn);
        emit log_named_decimal_uint("User1: Price Sell price return",
                                    user1PayBackAmount
                                    , 18);
        ERCBondingCurveContract.burn(user1AmountToBurn);
        assertEq(USDTTokenContract.balanceOf(address(User1)),
                         user1PayBackAmount, "Should be equal to user1PayBackAmount");
        vm.stopPrank();

        vm.startPrank(User2);
        uint256 user2AmountToBurn = IERC20(ERCBondingCurveContract).balanceOf(address(User2));
        uint256 user2PayBackAmount = ERCBondingCurveContract.calculateContinuousBurnReturn(user2AmountToBurn);
        emit log_named_decimal_uint("User2: Price Sell price return",
                                    user2PayBackAmount
                                    , 18);
        ERCBondingCurveContract.burn(user2AmountToBurn);
        assertEq(USDTTokenContract.balanceOf(address(User2)),  
                        user2PayBackAmount);
        vm.stopPrank();

    }


    function testPriceDropsAfterwhaleBurn() public {
        testPriceIncreaseAfterWhalePurchase();
        vm.startPrank(whale);
            emit log_named_decimal_uint("Current BTC price before whale sell off ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);
        uint initialPrice = ERCBondingCurveContract.getBTCPrice();
        uint256 whaleBTCBal = IERC20(ERCBondingCurveContract).balanceOf(address(whale));
        uint256 whalePayBackAmount = ERCBondingCurveContract.calculateContinuousBurnReturn(whaleBTCBal);
            ERCBondingCurveContract.burn(whaleBTCBal);
            emit log_named_decimal_uint("Current BTC price after whale sell off ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);
        // Calculate that the price drops by 50%
        uint expectedDropsPricePercentage = 95; // 95%
        uint expectedPriceDrops = initialPrice * (100 - expectedDropsPricePercentage) / 100;
        console.log("expected price drops", expectedPriceDrops);
        uint newPrice = ERCBondingCurveContract.getBTCPrice();
        assertLe(newPrice, expectedPriceDrops, "Price drop is less than expected percentage");
        vm.stopPrank();
    }









    



}





contract USDT is ERC20 {
    constructor() ERC20("USDT tokens", "USDT") {
        _mint(msg.sender, 100000 * 10 ** 18);
    }   
}
