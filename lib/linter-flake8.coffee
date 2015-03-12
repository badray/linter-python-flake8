linterPath = atom.packages.getLoadedPackage("linter").path

Linter = require "#{linterPath}/lib/linter"
{findFile} = require "#{linterPath}/lib/utils"

class LinterFlake8 extends Linter
  @syntax: ['source.python']

  cmd: ['flake8']

  linterName: 'flake8'

  # A regex pattern used to extract information from the executable's output.
  regex:
    '(.*?):(?<line>\\d+):(?<col>\\d+): ' +
    '(?<message>((?<error>E11|E9)|' +
    '(?<warning>W|E|F4|F84|N*|C|D|Q)|F)\\d+ .*?)\r?\n'

  constructor: (editor)->
    super(editor)

    @configFile = findFile @cwd, ['setup.cfg', 'tox.ini', '.pep8']

    atom.config.observe 'linter-flake8.executableDir', =>
      @executablePath = atom.config.get 'linter-flake8.executableDir'

    atom.config.observe 'linter-flake8.binaryName', =>
      @updateCommand()

    atom.config.observe 'linter-flake8.maxLineLength', =>
      @updateCommand()

    atom.config.observe 'linter-flake8.ignoreErrorCodes', =>
      @updateCommand()

    atom.config.observe 'linter-flake8.maxComplexity', =>
      @updateCommand()

    atom.config.observe 'linter-flake8.selectErrors', =>
      @updateCommand()

    atom.config.observe 'linter-flake8.hangClosing', =>
      @updateCommand()

  destroy: ->
    atom.config.unobserve 'linter-flake8.executableDir'
    atom.config.unobserve 'linter-flake8.binaryName'
    atom.config.unobserve 'linter-flake8.maxLineLength'
    atom.config.unobserve 'linter-flake8.ignoreErrorCodes'
    atom.config.unobserve 'linter-flake8.maxComplexity'
    atom.config.unobserve 'linter-flake8.selectErrors'
    atom.config.unobserve 'linter-flake8.hangClosing'

  updateCommand: ->
    binary_name = atom.config.get 'linter-flake8.binaryName'
    maxLineLength = atom.config.get 'linter-flake8.maxLineLength'
    errorCodes = atom.config.get 'linter-flake8.ignoreErrorCodes'
    maxComplexity = atom.config.get 'linter-flake8.maxComplexity'
    selectErrors = atom.config.get 'linter-flake8.selectErrors'
    hangClosing = atom.config.get 'linter-flake8.hangClosing'

    cmd = [binary_name]

    if maxLineLength
      cmd.push '--max-line-length', maxLineLength

    if @configFile
      cmd.push '--config', @configFile

    if errorCodes and errorCodes.length > 0
      cmd.push '--ignore', errorCodes.toString()

    if maxComplexity
      cmd.push '--max-complexity', maxComplexity

    if selectErrors
      cmd.push '--select', selectErrors.toString()

    if hangClosing
      cmd.push '--hang-closing'

    @cmd = cmd

module.exports = LinterFlake8
