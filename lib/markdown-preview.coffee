url = require 'url'
{fs} = require 'atom'
MarkdownPreviewView = require './markdown-preview-view'

module.exports =
  activate: ->
    atom.workspaceView.command 'markdown-preview:show', =>
      @show()

    atom.project.registerOpener (urlToOpen) ->
      {protocol, pathname} = url.parse(urlToOpen)
      return unless protocol is 'markdown-preview:' and fs.isFileSync(pathname)
      new MarkdownPreviewView(pathname)

  show: ->
    activePane = atom.workspaceView.getActivePane()
    editor = activePane.activeItem

    unless editor.getGrammar?().scopeName is "source.gfm"
      console.warn("Can not render markdown for '#{editor.getUri() ? 'untitled'}'")
      return

    {previewPane, previewItem} = @getExistingPreview(editor)
    filePath = editor.getPath()
    if previewItem?
      previewPane.showItem(previewItem)
      previewItem.renderMarkdown()
    else if nextPane = activePane.getNextPane()
      nextPane.showItem(new MarkdownPreviewView(filePath))
    else
      activePane.splitRight(new MarkdownPreviewView(filePath))
    activePane.focus()

  getExistingPreview: (editor) ->
    uri = "markdown-preview://#{editor.getPath()}"
    for previewPane in atom.workspaceView.getPanes()
      previewItem = previewPane.itemForUri(uri)
      return {previewPane, previewItem} if previewItem?
    {}
