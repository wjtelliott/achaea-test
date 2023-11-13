-- todo: delete this file. use the src/ directory instead


require('unknown') -- unknown functions, probably from the mudlet api
require('pipeline') -- foundation logic
require('util') -- util helpers
require('bard-context') -- context helpers
require('bard-conditionals') -- bard-specific conditional helpers (pipeline functions)
require('bard-actions') -- bard-specific actions (pipeline functions)

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
)(bardContext)