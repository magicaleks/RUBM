// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import { IDiamondCut } from "../../interfaces/IDiamondCut.sol";
import { DiamondLib } from "../../libraries/DiamondLib.sol";

contract DiamondCutFacet is IDiamondCut {
    function diamondCut(FacetCut[] memory _diamondCut) external {
      DiamondLib.requireOwner();
      DiamondLib.diamondCut(_diamondCut);
    }
}
