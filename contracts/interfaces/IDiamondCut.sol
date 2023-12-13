// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import { IDiamond } from "../interfaces/IDiamond.sol";

interface IDiamondCut is IDiamond {

  event DiamondCut(FacetCut[] _diamondCut);
  
  function diamondCut(
    FacetCut[] memory _diamondCut
  ) external;
}
