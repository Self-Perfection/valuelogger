import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: addValuePage

    canAccept: false

    property string parameterName: "value"
    property string parameterDescription: "value"
    property string pageTitle: "value"  /* Add or Edit*/
    property string value: "value"
    property string annotation: "annotation"
    property string nowDate: "value"
    property string nowTime: "value"
    property bool paired: false

    Component.onCompleted:
    {
        /* Check are we adding new, or editing existing one */
        if (nowDate == "value" && nowTime == "value" && value == "value")
        {
            var tmp = new Date()
            updateDateTime(Qt.formatDateTime(tmp, "yyyy-MM-dd"), Qt.formatDateTime(tmp, "hh:mm:ss"))
            pageTitle = qsTr("Add")
        }
        else
        {
            if (nowTime == "")
                nowTime = "00:00:00"
            updateDateTime(nowDate, nowTime)
            valueField.text = (value == "value") ? "" : value
            annotationField.text = (value == "value") ? "" : annotation
            pageTitle = (value == "value") ? qsTr("Add") : qsTr("Edit")
        }
    }

    function updateDateTime (newDate, newTime)
    {
        console.log("newdate " + newDate + " newtime " + newTime)
        nowDate = Qt.formatDateTime(new Date(newDate), "yyyy-MM-dd")
        nowTime = Qt.formatDateTime(new Date(newDate + " " + newTime), "hh:mm:ss")
        console.log("nowdate " + nowDate + " nowtime " + nowTime)

        dateNow.text = Qt.formatDateTime(new Date(nowDate), "dd.MM.yyyy") + " " + Qt.formatDateTime(new Date(nowDate + " " + nowTime), "hh:mm:ss")

        console.log("dateNow " + dateNow.text)
    }

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            value = valueField.text.replace(",",".")
            annotation = annotationField.text
        }
    }

    SilicaFlickable
    {
        id: flick

        anchors.fill: parent
        contentHeight: col.height
        width: parent.width

        VerticalScrollDecorator { flickable: flick }

        Column
        {
            id: col
            spacing: Theme.paddingSmall
            anchors.top: dialogHeader.bottom
            width: addValuePage.width

            DialogHeader
            {
                id: dialogHeader
                acceptText: pageTitle + qsTr(" value")
                cancelText: qsTr("Cancel")
            }

            Row
            {
                x: Theme.paddingLarge
                Image
                {
                    id: pairIcon
                    source: "image://theme/icon-m-link"
                    anchors.verticalCenter: parent.verticalCenter
                    visible: paired
                }
                Column
                {
                    anchors.verticalCenter: parent.verticalCenter
                    Label
                    {
                        text: parameterName
                        font.bold: true
                    }
                    Label
                    {
                        text: parameterDescription
                        color: Theme.secondaryColor
                    }
                }
            }

            SectionHeader
            {
                text: qsTr("Timestamp")
            }

            Row
            {
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge

                Label
                {
                    id: dateNow
                    text: "unknown"
                    width: parent.width - modifyDateButton.width - modifyTimeButton.width
                    anchors.verticalCenter: parent.verticalCenter
                }

                IconButton
                {
                    id: modifyDateButton
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-lock-calendar"
                    onClicked:
                    {
                        console.log("modifyDateButton clicked")

                        var dialogDate = pageStack.push(pickerDate, { date: new Date(nowDate) })
                               dialogDate.accepted.connect(function()
                               {
                                   console.log("You chose: " + dialogDate.dateText)
                                   // use date, as dateText return varies
                                   var d = dialogDate.date
                                   updateDateTime(Qt.formatDateTime(new Date(d), "yyyy-MM-dd"), nowTime)
                               })
                    }
                    Component
                    {
                        id: pickerDate
                        DatePickerDialog {}
                    }

                }
                IconButton
                {
                    id: modifyTimeButton
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-time-date"
                    onClicked:
                    {
                        console.log("modifyTimeButton clicked")

                        console.log("hour " + Qt.formatDateTime(new Date(nowDate + " " + nowTime), "hh"))
                        console.log("minute " + Qt.formatDateTime(new Date(nowDate + " " + nowTime), "mm"))

                        var dialogTime = pageStack.push(pickerTime, {
                                                            hour: Qt.formatDateTime(new Date(nowDate + " " + nowTime), "hh"),
                                                            minute: Qt.formatDateTime(new Date(nowDate + " " + nowTime), "mm")})
                              dialogTime.accepted.connect(function()
                              {
                                  console.log("You chose: " + dialogTime.timeText)
                                  var tt = dialogTime.timeText + ":00"
                                  if (dialogTime.hour < 10)
                                      tt = "0" + tt
                                  updateDateTime(nowDate, tt)
                              })

                    }
                    Component
                    {
                        id: pickerTime
                        TimePickerDialog {}
                    }

                }
            }

            SectionHeader
            {
                text: qsTr("Value")
            }

            TextField
            {
                id: valueField
                focus: true
                width: parent.width
                label: qsTr("Value")
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.primaryColor
                placeholderText: qsTr("Enter new value here")
                onTextChanged: addValuePage.canAccept = text.length > 0
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegExpValidator { regExp: /-?\d+([,|\.]?\d+)?/ }
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: annotationField.focus = true
            }

            SectionHeader
            {
                text: qsTr("Annotation")
            }

            TextField
            {
                id: annotationField
                focus: false
                width: parent.width
                label: qsTr("Annotation")
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.primaryColor
                placeholderText: qsTr("Enter annotation here")
                EnterKey.enabled: valueField.text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: addValuePage.accept()
                onFocusChanged: if (focus) flick.scrollToBottom()
            }
        }
    }
}
