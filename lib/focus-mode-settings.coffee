{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusModeSettings extends FocusModeBase

    constructor: ->
        super('FocusModeSettings')
        @fullScreen = @getConfig('atom-focus-mode.whenFocusModeIsActivated.enterFullScreen') or false
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
            "useLargeFontSize": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.useLargeFontSize') or false,
                "cssClass": "afm-larger-font"
            }
        }
        console.log("Focus mode config = ", @config)
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
            'atom-focus-mode.whenFocusModeIsActivated.useLargeFontSize',
            (value) => @applyConfigSetting("useLargeFontSize", value)
        ))

        return configSubscribers


    applyConfigSetting: (configKey, value) =>
        console.log("configKey = ", configKey, " value = ", value, " initially set as ", @config[configKey].activated)
        @config[configKey].activated = value
        console.log("configKey = ", configKey, " value = ", value, " now set as ", @config[configKey].activated)
        if (@config[configKey].activated)
            @addCssClass(@getBodyTagElement(), @config[configKey].cssClass)
        else
            @removeCssClass(@getBodyTagElement(), @config[configKey].cssClass)


    dispose: =>
        @configSubscribers.dispose() if @configSubscribers


module.exports = FocusModeSettings
