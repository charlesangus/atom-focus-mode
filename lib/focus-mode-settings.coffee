{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusModeSettings extends FocusModeBase

    constructor: ->
        super('FocusModeSettings')
        @fullScreen = @getConfig('atom-focus-mode.whenFocusModeIsActivated.enterFullScreen') or false
        @useTypeWriterMode = @getConfig('atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode') or false
        @config = {
            "hideSidePanels": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideSidePanels') or false,
                "cssClass": "afm-no-side-panels"
            },
            "hideTabBar": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideTabBar') or false,
                "cssClass": "afm-no-tab-bar"
            },
            "hideFooterBar": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideFooterBar') or false,
                "cssClass": "afm-no-footer"
            },
            "hideLineNumbers": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideLineNumbers') or false,
                "cssClass": "afm-no-line-numbers"
            },
            "hideLineWrapGuide": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideLineWrapGuide') or false,
                "cssClass": "afm-no-wrap-guide"
            },
            "useLargeFontSize": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.useLargeFontSize') or false,
                "cssClass": "afm-larger-font"
            }
        }
        @applyConfigSettings()
        @configSubscribers = @registerConfigSubscribers()


    applyConfigSettings: =>
        for key, value of @config
            if (@config[key].activated)
                @addCssClass(@getBodyTagElement(), @config[key].cssClass)


    registerConfigSubscribers: =>
        configSubscribers = new CompositeDisposable()

        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.enterFullScreen',
            (value) => @fullScreen = value if value?
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode',
            (value) => @useTypeWriterMode = value if value?
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideSidePanels',
            (value) => @applyConfigSetting("hideSidePanels", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideTabBar',
            (value) => @applyConfigSetting("hideTabBar", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideFooterBar',
            (value) => @applyConfigSetting("hideFooterBar", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideLineNumbers',
            (value) => @applyConfigSetting("hideLineNumbers", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideLineWrapGuide',
            (value) => @applyConfigSetting("hideLineWrapGuide", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.useLargeFontSize',
            (value) => @applyConfigSetting("useLargeFontSize", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.focusModeLineOpacity',
            (value) => @applyFocusLineCssClass(value)
        ))

        return configSubscribers


    applyConfigSetting: (configKey, value) =>
        @config[configKey].activated = value

        if (@config[configKey].activated)
            @addCssClass(@getBodyTagElement(), @config[configKey].cssClass)
        else
            @removeCssClass(@getBodyTagElement(), @config[configKey].cssClass)


    applyFocusLineCssClass: (opacityValue) =>
        if (opacityValue is "100%")
            @addCssClass(@getBodyTagElement(), "line-100")
        else
            @removeCssClass(@getBodyTagElement(), "line-100")


    toggleTypeWriterScrollingSetting: ()=>
        msg = if @useTypeWriterMode then "Focus Mode Type Writer Scrolling Off" else "Focus Mode Type Writer Scrolling On"
        @setConfig("atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode", !@useTypeWriterMode)
        @getAtomNotificationsInstance().addInfo(msg)

    dispose: =>
        @configSubscribers.dispose() if @configSubscribers


module.exports = FocusModeSettings
