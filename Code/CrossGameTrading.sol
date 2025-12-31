pragma solidity >=0.5.0 <0.6.0;

contract CrossGameTrading {  // Game assets include but no limited to weapons and game skins

    event NewAsset(uint assetId, string name, uint price);
    event TradeExecuted(uint assetSoldId, uint assetBoughtId, uint amountSold, uint amountBought);

    // Asset struct
    struct Asset {
        string name;
        uint price;  // For simplicity, price is a uint that could be used in Automated Market Maker (AMM) calculation
        uint balance;  // How much of this asset is in the pool
    }

    Asset[] public assets;

    function _createAsset(string memory _name, uint _price, uint _balance) private {
        uint id = assets.push(Asset(_name, _price, _balance)) - 1;  // Correspond to the parameter assetId
        emit NewAsset(id, _name, _price);
    }

    function createInitialAsset(string memory _name, uint _price, uint _balance) public {
        _createAsset(_name, _price, _balance);
    }

    function getAsset(uint _id) public view returns (string memory, uint, uint) {
        Asset memory a = assets[_id];
        return (a.name, a.price, a.balance);
    }

    // AMM trade function (x * y = k style)
    function tradeAsset(uint assetSoldId, uint assetBoughtId, uint amountSold) public {
        require(assetSoldId != assetBoughtId, "Cannot trade the same asset!");
        require(assetSoldId < assets.length && assetBoughtId < assets.length, "Invalid asset Identity Document (ID)!");

        Asset storage sold = assets[assetSoldId];
        Asset storage bought = assets[assetBoughtId];

        // Calculate constant k
        uint k = sold.balance * bought.balance;

        // Increase sold asset balance
        sold.balance += amountSold;

        // Calculate new bought asset balance
        uint newBoughtBalance = k / sold.balance;
        uint amountBought = bought.balance - newBoughtBalance;

        require(amountBought > 0, "Trade results in zero output!");

        // Decrease bought asset balance
        bought.balance = newBoughtBalance;

        emit TradeExecuted(assetSoldId, assetBoughtId, amountSold, amountBought);
    }

}