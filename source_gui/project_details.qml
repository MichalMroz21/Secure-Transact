import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"
import "small_gui_components"
import "app_style"

Page {
    id: projectDetailsPage

    SpacingObjects { id: spacingObjects }

    property int currentIndex

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    TaskList {
        currentIndex: projectDetailsPage.currentIndex
    }

}
