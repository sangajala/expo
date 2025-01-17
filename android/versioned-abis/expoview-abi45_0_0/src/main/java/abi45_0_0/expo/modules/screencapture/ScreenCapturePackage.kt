package abi45_0_0.expo.modules.screencapture

import android.content.Context

import abi45_0_0.expo.modules.core.BasePackage
import abi45_0_0.expo.modules.core.ExportedModule

class ScreenCapturePackage : BasePackage() {
  override fun createExportedModules(context: Context): List<ExportedModule> {
    return listOf(ScreenCaptureModule(context) as ExportedModule)
  }
}
