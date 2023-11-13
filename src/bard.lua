local pipeline = require('src/pipeline') -- foundation logic
local context = require('src/bard/bard-context') -- context helpers
local conditionals = require('src/bard/bard-conditionals') -- bard-specific conditional helpers (pipeline functions)
local actions = require('src/bard/bard-actions') -- bard-specific actions (pipeline functions)

-- pipeline helpers
local pipe, log, ifThe, ifNotThe, ifTheElse = pipeline.unpack()
local breakPipe = pipeline.breakPipe

-- conditionals
local playerIsClass,
  reqOtherIsEmpty,
  opponentIsLocked,
  salveLock,
  shouldChaseTarget,
  shouldLungeTarget =
  conditionals.playerIsClass,
  conditionals.reqOtherIsEmpty,
  conditionals.opponentIsLocked,
  conditionals.salveLock,
  conditionals.shouldChaseTarget,
  conditionals.shouldLungeTarget

-- actions
local setReqOther,
  initBard,
  selectTunesmith,
  chaseTarget,
  lungeTarget,
  queueingLogic,
  lockedRoute,
  lockRoute =
  actions.setReqOther,
  actions.initBard,
  actions.selectTunesmith,
  actions.chaseTarget,
  actions.lungeTarget,
  actions.queueingLogic,
  actions.lockedRoute,
  actions.lockRoute

-- bard entry point
pipe(
  ifNotThe(playerIsClass('Bard'))(breakPipe()),
  ifNotThe(reqOtherIsEmpty())(setReqOther()),
  initBard(),
  selectTunesmith(),
  ifTheElse(opponentIsLocked())({
    actions = { log('opp is locked'), lockedRoute() },
    elseActions = { log('opponent is not locked'), lockRoute() }
  }),
  queueingLogic(),
  ifTheElse(salveLock())({
    actions = { log('salve lock logic') },
    elseActions = { log('not salve lock logic') }
  }),
  ifThe(shouldChaseTarget())(chaseTarget()),
  ifThe(shouldLungeTarget())(lungeTarget())
)(context)