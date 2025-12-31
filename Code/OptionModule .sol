// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GameOption {
    enum OptionType { Call, Put }

    struct Option {
        address buyer;
        address seller;
        address underlyingAsset;
        uint256 strikePrice; 
        uint256 premium;    
        uint256 expiry;
        OptionType optionType;
        bool isFractional;
        bool exercised;
    }

    uint256 public nextOptionId;
    mapping(uint256 => Option) public options;

    function createOption(
        address _underlyingAsset,
        uint256 _strikePrice,
        uint256 _premium,
        uint256 _expiry,
        OptionType _optionType,
        bool _isFractional
    ) external payable returns (uint256) {
        require(msg.value == _premium, "Must pay premium");
        options[nextOptionId] = Option({
            buyer: msg.sender,
            seller: address(this), 
            underlyingAsset: _underlyingAsset,
            strikePrice: _strikePrice,
            premium: _premium,
            expiry: _expiry,
            optionType: _optionType,
            isFractional: _isFractional,
            exercised: false
        });

        return nextOptionId++;
    }

    function exercise(uint256 optionId) external payable {
        Option storage opt = options[optionId];
        require(block.timestamp <= opt.expiry, "Option expired");
        require(!opt.exercised, "Already exercised");
        require(msg.value == opt.strikePrice, "Incorrect strike payment");
        require(msg.sender == opt.buyer, "Only buyer can exercise");

        opt.exercised = true;

    }

    function isInTheMoney(uint256 optionId) external view returns (bool) {
        Option memory opt = options[optionId];
        return block.timestamp < opt.expiry && !opt.exercised;
    }

    function getOption(uint256 optionId) external view returns (Option memory) {
        return options[optionId];
    }
}