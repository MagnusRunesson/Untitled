	ifnd _graphics_lib_i_

_graphics_lib_i_

;------ BitMap primitives ---
_LVOBltBitMap equ -$1e
_LVOBltTemplate equ -$24 

;------ Text routines ---
_LVOClearEOL equ -$2a 
_LVOClearScreen equ -$30 
_LVOTextLength equ -$36 
_LVOText equ -$3c 
_LVOSetFont equ -$42 
_LVOOpenFont equ -$48 
_LVOCloseFont equ -$4e 
_LVOAskSoftStyle equ -$54 
_LVOSetSoftStyle equ -$5a 

;------	Gels routines ---
_LVOAddBob equ -$60 
_LVOAddVSprite equ -$66 
_LVODoCollision equ -$6c 
_LVODrawGList equ -$72 
_LVOInitGels equ -$78 
_LVOInitMasks equ -$7e 
_LVORemIBob equ -$84 
_LVORemVSprite equ -$8a 
_LVOSetCollision equ -$90 
_LVOSortGList equ -$96 
_LVOAddAnimOb equ -$9c 
_LVOAnimate equ -$a2 
_LVOGetGBuffers equ -$a8 
_LVOInitGMasks equ -$ae 

;------	General graphics routines ---
_LVODrawEllipse equ -$b4 
_LVOAreaEllipse equ -$ba 
_LVOLoadRGB4 equ -$c0 
_LVOInitRastPort equ -$c6 
_LVOInitVPort equ -$cc 
_LVOMrgCop equ -$d2 
_LVOMakeVPort equ -$d8 
_LVOLoadView equ -$de 
_LVOWaitBlit equ -$e4 
_LVOSetRast equ -$ea 
_LVOMove equ -$f0 
_LVODraw equ -$f6 
_LVOAreaMove equ -$fc 
_LVOAreaDraw equ -$102 
_LVOAreaEnd equ -$108 
_LVOWaitTOF equ -$10e 
_LVOQBlit equ -$114 
_LVOInitArea equ -$11a 
_LVOSetRGB4 equ -$120 
_LVOQBSBlit equ -$126 
_LVOBltClear equ -$12c 
_LVORectFill equ -$132 
_LVOBltPattern equ -$138 
_LVOReadPixel equ -$13e 
_LVOWritePixel equ -$144 
_LVOFlood equ -$14a 
_LVOPolyDraw equ -$150 
_LVOSetAPen equ -$156 
_LVOSetBPen equ -$15c 
_LVOSetDrMd equ -$162 
_LVOInitView equ -$168 
_LVOCBump equ -$16e 
_LVOCMove equ -$174 
_LVOCWait equ -$17a 
_LVOVBeamPos equ -$180 
_LVOInitBitMap equ -$186 
_LVOScrollRaster equ -$18c 
_LVOWaitBOVP equ -$192 
_LVOGetSprite equ -$198 
_LVOFreeSprite equ -$19e 
_LVOChangeSprite equ -$1a4 
_LVOMoveSprite equ -$1aa 
_LVOLockLayerRom equ -$1b0 
_LVOUnlockLayerRom equ -$1b6 
_LVOSyncSBitMap equ -$1bc 
_LVOCopySBitMap equ -$1c2 
_LVOOwnBlitter equ -$1c8 
_LVODisownBlitter equ -$1ce 
_LVOInitTmpRas equ -$1d4 
_LVOAskFont equ -$1da 
_LVOAddFont equ -$1e0 
_LVORemFont equ -$1e6 
_LVOAllocRaster equ -$1ec 
_LVOFreeRaster equ -$1f2 
_LVOAndRectRegion equ -$1f8 
_LVOOrRectRegion equ -$1fe 
_LVONewRegion equ -$204 
_LVOClearRectRegion equ -$20a 
_LVOClearRegion equ -$210 
_LVODisposeRegion equ -$216 
_LVOFreeVPortCopLists equ -$21c 
_LVOFreeCopList equ -$222 
_LVOClipBlit equ -$228 
_LVOXorRectRegion equ -$22e 
_LVOFreeCprList equ -$234 
_LVOGetColorMap equ -$23a 
_LVOFreeColorMap equ -$240 
_LVOGetRGB4 equ -$246 
_LVOScrollVPort equ -$24c 
_LVOUCopperListInit equ -$252 
_LVOFreeGBuffers equ -$258 
_LVOBltBitMapRastPort equ -$25e 
_LVOOrRegionRegion equ -$264 
_LVOXorRegionRegion equ -$26a 
_LVOAndRegionRegion equ -$270 
_LVOSetRGB4CM equ -$276 
_LVOBltMaskBitMapRastPort equ -$27c 
_LVOAttemptLockLayerRom equ -$28e 

;--- functions in V36 or higher (Release 2.0) ---*/
_LVOGfxNew equ -$294 
_LVOGfxFree equ -$29a 
_LVOGfxAssociate equ -$2a0 
_LVOBitMapScale equ -$2a6 
_LVOScalerDiv equ -$2ac 
_LVOTextExtent equ -$2b2 
_LVOTextFit equ -$2b8 
_LVOGfxLookUp equ -$2be 
_LVOVideoControl equ -$2c4 
_LVOVideoControlTags equ -$2c4 
_LVOOpenMonitor equ -$2ca 
_LVOCloseMonitor equ -$2d0 
_LVOFindDisplayInfo equ -$2d6 
_LVONextDisplayInfo equ -$2dc 
_LVOGetDisplayInfoData equ -$2f4 
_LVOFontExtent equ -$2fa 
_LVOReadPixelLine8 equ -$300 
_LVOWritePixelLine8 equ -$306 
_LVOReadPixelArray8 equ -$30c 
_LVOWritePixelArray8 equ -$312 
_LVOGetVPModeID equ -$318 
_LVOModeNotAvailable equ -$31e 
_LVOEraseRect equ -$32a 
_LVOExtendFont equ -$330 
_LVOExtendFontTags equ -$330 
_LVOStripFont equ -$336 

;--- functions in V39 or higher (Release 3) ---*/
_LVOCalcIVG equ -$33c 
_LVOAttachPalExtra equ -$342 
_LVOObtainBestPenA equ -$348 
_LVOObtainBestPen equ -$348 
_LVOSetRGB32 equ -$354 
_LVOGetAPen equ -$35a 
_LVOGetBPen equ -$360 
_LVOGetDrMd equ -$366 
_LVOGetOutlinePen equ -$36c 
_LVOLoadRGB32 equ -$372 
_LVOSetChipRev equ -$378 
_LVOSetABPenDrMd equ -$37e 
_LVOGetRGB32 equ -$384 
_LVOAllocBitMap equ -$396 
_LVOFreeBitMap equ -$39c 
_LVOGetExtSpriteA equ -$3a2 
_LVOGetExtSprite equ -$3a2 
_LVOCoerceMode equ -$3a8 
_LVOChangeVPBitMap equ -$3ae 
_LVOReleasePen equ -$3b4 
_LVOObtainPen equ -$3ba 
_LVOGetBitMapAttr equ -$3c0 
_LVOAllocDBufInfo equ -$3c6 
_LVOFreeDBufInfo equ -$3cc 
_LVOSetOutlinePen equ -$3d2 
_LVOSetWriteMask equ -$3d8 
_LVOSetMaxPen equ -$3de 
_LVOSetRGB32CM equ -$3e4 
_LVOScrollRasterBF equ -$3ea 
_LVOFindColor equ -$3f0 
_LVOAllocSpriteDataA equ -$3fc 
_LVOAllocSpriteData equ -$3fc 
_LVOChangeExtSpriteA equ -$402 
_LVOChangeExtSprite equ -$402 
_LVOFreeSpriteData equ -$408 
_LVOSetRPAttrsA equ -$40e 
_LVOSetRPAttrs equ -$40e 
_LVOGetRPAttrsA equ -$414 
_LVOGetRPAttrs equ -$414 
_LVOBestModeIDA equ -$41a 
_LVOBestModeID equ -$41a 
 
;--- functions in V40 or higher (Release 3.1) ---
_LVOWriteChunkyPixels equ -$420 

	endif