// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IDiamond {

  enum FacetCutAction {Add, Update, Remove}

  struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
  }
}
