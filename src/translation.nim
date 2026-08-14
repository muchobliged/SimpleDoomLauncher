

type
  Translation* = object
    addport*: string
    settings*: string
    extracommands*: string
    extracommandsFAQ*: seq[string]
    play*: string
    portname*: string
    selectexecutable*: string
    commandspreset*: string
    extraformats*: string
    extraformatsFAQ*: string
    add*: string
    configure*: string
    rename*: string
    delete*: string
    configurationrename*: string
    configurationdelete*: string
    save*: string
    addcustompwad*: string
    theme*: string
    iwadsdirectory*: string
    iwadsdirectoryHelper*: string
    pwadsdirectory*: string
    pwadsdirectoryHelper*: string
    makeexecportable*: string
    makeexecportableFAQ*: string
    closeonlaunch*: string
    closeonlaunchFAQ*: string
    about*: string
    extracredits*: string
    back*: string
    removeport*: string
    yes*: string
    no*: string
    configureport*: string
    createdby*: string
    iwadsnotfound*: string
    pwadsnotfound*: string
    selectproperpwadsdir*: string
    selectproperiwadsdir*: string
    tips*: seq[string]
    removeportWarning*: seq[string]
    select*: string
    addzdlconfig*: string
    selectzdlconfig*: string
    language*: string
    removeconfigWarning*: seq[string]
    copy*: string
    paste*: string
    importCFG*: string
    exportCFG*: string
    checkForUpdates*: string
    checkForUpdatesFAQ*: string
    updateFound*: seq[string]

var trans*: Translation



proc setLang*(lan: int = 0) =
  case lan:
    of 1:
      trans = Translation(
        addport: "Добавить порт",
        settings: "Настройки",
        extracommands: "Доп. параметры",
        play: "Играть",
        portname: "Название порта",
        selectexecutable: "Выбрать файл",
        commandspreset: "Пресет параметров:",
        extraformats: "Доп. форматы:",
        extraformatsFAQ: "Разрешить дополнительные форматы, например .pk3 и .pk7",
        add: "Добавить",
        configure: "Настроить",
        rename: "Переименовать",
        delete: "Удалить",
        configurationrename: "Переименование конфигурации",
        configurationdelete: "Удаление конфигурации",
        save: "Сохранить",
        addcustompwad: "Добавить внешний PWAD",
        theme: "Тема:",
        iwadsdirectory: "Директория IWAD`ов:",
        iwadsdirectoryHelper: "Директория с IWADами",
        pwadsdirectory: "Директория PWAD`ов:",
        pwadsdirectoryHelper: "Директория с PWADами",
        makeexecportable: "Запускать портативно:",
        makeexecportableFAQ: "Использовать папку .home рядом с исполняемым файлом",
        closeonlaunch: "Закрыть при запуске: ",
        closeonlaunchFAQ: "Закрыть этот лаунчер при запуске порта",
        about: "О программе",
        extracredits: "Благодарности:",
        back: "Назад",
        removeport: "Удалить порт",
        select: "Выбрать",
        yes: "Да",
        no: "Нет",
        configureport: "Настроить порт",
        createdby: "Автор: ",
        extracommandsFAQ: @["Здесь можно задать игровые параметры запуска:", "", "-skill 4 -nosound", "", "Также можно задать параметры порта. Они должны", "быть написаны первыми и закрываться ; символом:", "", "--socket=x11 --nosocket=wayland; -skill 4 -nosound"],
        iwadsnotfound: "IWAD`ы не найдены!",
        pwadsnotfound: "PWAD`ы не найдены!",
        selectproperpwadsdir: "Выберите корректную директорию с PWAD`ами в настройках",
        selectproperiwadsdir: "Выберите корректную директорию с IWAD`ами в настройках",
        tips: @["Несколько советов:", "- ПКМ по выбранному порту для настройки", "", "- ПКМ по выбранному конфигу, чтобы сохранить,", "скопировать, переименовать или удалить его", "", "- можно менять порядок портов и конфигов путем", "перетаскивания с зажатой ЛКМ", "", "- добавленные PWAD`ы можно перетаскивать, это", "изменит порядок запуска", "", "- добавленные PWAD`ы можно удалить, нажав ПКМ", "", "- для быстрого добавления порта вы можете", "перетащить исполняемый файл в левую часть окна", "", "- добавить внешний PWAD можно двумя способами:", "нажав на соответствующую кнопку или перетащив", "файл в правую часть окна", "", "- импортировать .zdl можно двумя способами:", "ПКМ по кнопке добавления конфигурации или", "перетащив файл в правую часть окна"],
        removeportWarning: @["Удалить выбранный порт и все его конфигурации?", "Вы уверены?"],
        removeconfigWarning: @["Удалить выбранную конфигурацию?", "Вы уверены?"],
        addzdlconfig: "Добавить ZDL",
        selectzdlconfig: "Выбрать ZDL конфиг",
        language: "Язык:",
        copy: "Скопировать",
        paste: "Вставить",
        importCFG: "Импортировать",
        exportCFG: "Сохранить",
        checkForUpdates: "Проверять обновления:",
        checkForUpdatesFAQ: "Проверять обновления при запуске - уведомит, если доступна новая версия",
        updateFound: @["Доступна новая версия!", "Хотите обновить?"]
        )
    else:
      trans = Translation(
        addport: "Add Port",
        settings: "Settings",
        extracommands: "Extra commands",
        play: "Play",
        portname: "Port name",
        selectexecutable: "Select executable",
        commandspreset: "Commands preset:",
        extraformats: "Extra formats:",
        extraformatsFAQ: "Allow formats like .pk3 and .pk7",
        add: "Add",
        configure: "Configure",
        rename: "Rename",
        delete: "Delete",
        configurationrename: "Configuration rename",
        save: "Save",
        addcustompwad: "Add custom PWAD",
        theme: "Theme:   ",
        iwadsdirectory: "IWADs directory:",
        iwadsdirectoryHelper: "Select directory with IWADs",
        pwadsdirectory: "PWADs directory:",
        pwadsdirectoryHelper: "Select directory with PWADs",
        makeexecportable: "Launch as portable:",
        makeexecportableFAQ: "Use .home folder near executable",
        closeonlaunch: "Close on launch:  ",
        closeonlaunchFAQ: "Close this launcher when the port is running",
        about: "About",
        extracredits: "Extra credits:",
        back: "Back",
        removeport: "Remove port",
        select: "Select",
        yes: "Yes",
        no: "No",
        configureport: "Configure port",
        createdby: "Created by: ",
        extracommandsFAQ: @["You can pass port arguments here:", "", "-skill 4 -nosound", "", "Also you can pass program arguments. They must be", "written first and closed with ; symbol:", "", "--socket=x11 --nosocket=wayland; -skill 4 -nosound"],
        iwadsnotfound: "IWADs not found!",
        pwadsnotfound: "PWADs not found!",
        selectproperpwadsdir: "Select proper PWADs directory in settings",
        selectproperiwadsdir: "Select proper IWADs directory in settings",
        tips: @["Some tips:", "- right click selected port to configure it", "", "- right click selected config to export, copy,", "rename or delete it", "", "- ports and configs are rearrangeable via", "holding left mouse button and dragging", "", "- items in the selected PWADs area are also", "rearrangeable - it changes order of loading", "", "- in the selected PWADs area press right mouse", "button to remove PWAD from the list", "", "- you can drag-n-drop executable into the", "left side of the main window", "", "- you can add extra PWAD that is not in the", "PWADs folder by either drag-n-dropping the file", "into the right side of the window or by pressing", "corresponding button", "", "- you can add .zdl config by either right click", "the add config button or by dragging", "the file into the right side of the window"],
        removeportWarning: @["Remove selected port and all related configs?", "Are you sure?"],
        removeconfigWarning: @["Remove selected config?", "Are you sure?"],
        addzdlconfig: "Import ZDL",
        selectzdlconfig: "Select ZDL config",
        language: "Language:",
        copy: "Copy",
        paste: "Paste",
        importCFG: "Import",
        exportCFG: "Export",
        checkForUpdates: "Check for updates:",
        checkForUpdatesFAQ: "Check for updates on startup - will notify if there is newer version",
        updateFound: @["New version available!", "Do you want to update?"]
        )
