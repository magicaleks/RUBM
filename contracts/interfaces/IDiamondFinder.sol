// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IDiamondFinder {
  
  struct Facet {
    address contractAddress;
    bytes4[] functionSelectors;
  }

  function findFacets() external returns(Facet[] memory);

  function findSelectors(address _facet) external returns(bytes4[] memory);

  function findAddresses() external returns(address[] memory);

  function findSelectorFacetAddress(bytes4 _selector) external returns(address);
}
