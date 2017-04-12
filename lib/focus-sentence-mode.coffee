{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusSentenceMode extends FocusModeBase

    constructor: () ->
        super('FocusSentenceMode')
        @isActivated = false
        @focusSentenceMarkerCache = {}
        @editorFileTypeCache = {}
        @focusSentenceModeClassName = "focus-sentence-mode"
        @sortAscending = (a, b) -> return a - b
        @sortDescending = (a, b) -> return b - a

    on: =>
        @isActivated = true
        @addCssClass(@getBodyTagElement(), @focusModeBodyCssClass)
        # @addCssClass(@getBodyTagElement(), @focusSentenceModeClassName) # TODO ?
        # textEditor = @getActiveTextEditor()
        cursor = @getActiveTextEditor().getLastCursor()
        @onCursorMove(cursor)

    off: =>
        @isActivated = false
        @removeSentenceModeMarkers()
        @focusSentenceMarkerCache = {}
        @removeCssClass(@getBodyTagElement(), @focusModeBodyCssClass)
        # @removeCssClass(@getBodyTagElement(), @focusSentenceModeClassName) # TODO ?


    getSentenceModeMarkerForEditor: (editor) =>
        marker = @focusSentenceMarkerCache[editor.id]
        if not marker
            marker = @createSentenceModeMarker(editor)
            @focusSentenceMarkerCache[editor.id] = marker
        return marker


    removeSentenceModeMarkers: =>
        for editor in @getAtomWorkspaceTextEditors()
            marker = @focusSentenceMarkerCache[editor.id]
            marker.destroy() if marker


    createSentenceModeMarker: (editor) =>
        cursorPosition = editor.getCursorBufferPosition()
        bufferRange = @getSentenceModeBufferRange(cursorPosition, editor)
        console.log("createSentenceModeMarker mode buffer range is ", bufferRange)
        marker = editor.markBufferRange(bufferRange, editor)
        editor.decorateMarker(marker, {type: 'highlight', class: "highlight-sentence"})
        # editor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)

        return marker

    onCursorMove: (cursor) =>
        editor = cursor.editor
        marker = @getSentenceModeMarkerForEditor(editor)
        cursorPosition = editor.getCursorBufferPosition()
        range = @getSentenceModeBufferRange(cursorPosition, editor)
        console.log("onCursorMove range = ", range)
        marker.setTailBufferPosition(range[0])
        marker.setHeadBufferPosition(range[1])


    getSentenceModeBufferRange: (cursorPosition, editor) =>
        lineText = editor.lineTextForBufferRow(cursorPosition.row)
        console.log("getSentenceModeBufferRange cuesor pos = ", cursorPosition, " lineText = ", lineText)
        charactersBeforeCursor = lineText.substring(0, cursorPosition.column)
        charactersAfterCursor = lineText.substring(cursorPosition.column)
        console.log("getSentenceModeBufferRange charactersBeforeCursor = ", charactersBeforeCursor, "charactersAfterCursor = ", charactersAfterCursor )
        startPoint = @getSentenceBufferStart(cursorPosition, charactersBeforeCursor, editor)
        endPoint = @getSentenceBufferEnd(cursorPosition, charactersAfterCursor, editor)
        console.log("getSentenceModeBufferRange returning ", [startPoint, endPoint])
        return [startPoint, endPoint]

    # ascenfing sort when we are searching after the cursor to identify the cursor sentence termination character
    # ascenfing sort when we are searching string before the cursor pos to find previous sentence termination character
    getSentenceTerminationCharacterIndex: (lineText, sortFunction) =>
        if @isEmptyLine(lineText)
            return 0
        else
            sentenceEndingCharacterIndexes = [
                lineText.indexOf('.')
                lineText.indexOf('!')
                lineText.indexOf('?')
            ]
            sentenceEndingCharacterIndexes.sort(sortFunction)
            filteredArray = sentenceEndingCharacterIndexes.filter((value)-> value > -1)
            # todo return first value that is not -1?
            console.log("sorted sentenceEndingCharacterIndexes = ", sentenceEndingCharacterIndexes, " filrered = ", filteredArray)
            #  order by desc ...first > value is furthest to right sentence end character
            # so use that, if it is -1 then no matches on this line
            return if filteredArray.length is 0 then -1 else Number(filteredArray[0])


    isEmptyLine: (lineText) ->
        return /^\s*$/.test(lineText)


    # find end of previous sentence/paragraph by detecting sentence termination
    # character at column and/or rowIndex less than cursor row/column or a previous blank line
    getSentenceBufferStart: (cursorPosition, charactersBeforeCursor, editor) =>
        rowIndex = cursorPosition.row
        bufferStartRow = 0
        bufferStartColumn = 0
        # end of previous sentence is on the cursor line?
        endSentenceCharIndex = @getSentenceTerminationCharacterIndex(charactersBeforeCursor, @sortDescending)
        if endSentenceCharIndex > -1
            bufferStartRow = rowIndex
            bufferStartColumn = endSentenceCharIndex
        # end of previous sentence was not on cursor line, move up to previous line and continue up through file
        else
            while rowIndex > 0
                # move up a line
                rowIndex = rowIndex - 1
                rowText = editor.lineTextForBufferRow(rowIndex)
                endSentenceCharIndex = @getSentenceTerminationCharacterIndex(rowText, @sortDescending)
                if endSentenceCharIndex > -1
                    bufferStartRow = rowIndex
                    bufferStartColumn = endSentenceCharIndex
                    break

        console.log("startRow = ", bufferStartRow, " start col = ", bufferStartColumn, " rowText = ", rowText)
        return [bufferStartRow, bufferStartColumn]


    getSentenceBufferEnd: (cursorPosition, charactersAfterCursor, editor) =>
        console.log("getSentenceBufferEnd charactersAfterCursor = ", charactersAfterCursor)
        rowIndex = cursorPosition.row
        cursorColumnIndex = cursorPosition.column
        bufferRowCount = editor.getLineCount() - 1
        bufferEndRow = bufferRowCount
        bufferEndColumn = 0
        # end of this sentence is on the cursor line?
        endSentenceCharIndex = @getSentenceTerminationCharacterIndex(charactersAfterCursor, @sortAscending)
        if endSentenceCharIndex > -1
            bufferEndRow = rowIndex
            bufferEndColumn = endSentenceCharIndex + cursorColumnIndex
        # Ending of this sentence is not on the cursor line. move down to next line and continur down file
        else
            while rowIndex < bufferRowCount
                rowIndex = rowIndex + 1
                rowText = editor.lineTextForBufferRow(rowIndex)
                endSentenceCharIndex = @getSentenceTerminationCharacterIndex(rowText, @sortDescending)

                console.log("in buffer end while rowIndex = ", rowIndex, " rowTExt = ", rowText, " endSentenceCharIndex = ", endSentenceCharIndex)

                if endSentenceCharIndex > -1
                    bufferEndRow = rowIndex
                    bufferEndColumn = endSentenceCharIndex
                    break;

        console.log("end bufferEndRow = ", bufferEndRow, " end bufferEndColumn = ", bufferEndColumn)
        return [bufferEndRow, bufferEndColumn]


module.exports = FocusSentenceMode
