// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;
contract RandomNumber {

    uint256 public totalSupply = 100; // 总供给

    uint256[100] public ids; // 用于计算可供mint的tokenId

    uint256 public mintCount; // 已mint数量

    /**
     * 利用链上产生的随机数来随机mint NFT，最大的难点在于随机tokenId的实现
     * 大体的思路：设定有totalSupply个杯子，每个杯子旁边有一个带有对应数字的小球
     * 那么，每次利用randomIndex先从杯子中获取，如果杯子中已经被取过了，则会取到的是其他后放入的球
     * 主要的逻辑在于三目运算符
     * 从当前杯子中取数字；如果ids[randomIndex] == 0表示这个杯子之前没有被抽取过，直接取出当前下标对应的数字；随后将最后一个杯子或者杯子旁边的数字赋值给刚刚该杯子
     * 因为下一次再次取时，容量会小一个；所以我们就将最后一个杯子剔除出去
     */
    function pickRandomUniqueId(uint256 random) public returns (uint256 tokenId) {
        uint256 len = totalSupply - mintCount; // 可mint数量
        require(len > 0, "mint close"); // 所有tokenId被mint完了
        uint256 randomIndex = random % len; // 获取链上随机数
        
        tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex; // 获取tokenId
        ids[randomIndex] = ids[len - 1] == 0 ? len - 1 : ids[len - 1]; // 更新ids 列表
        ids[len - 1] = 0; // 删除最后一个元素，能返还gas
        mintCount ++;
    }
}