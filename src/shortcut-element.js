import '@webcomponents/custom-elements'
import deburr from 'lodash.deburr'

let preventDuplicateEvent = false
/**
 * make sure the given fct is ran at most once every 10ms
 **/
function dedup (fct, event) {
  // if the lock it not in place
  if (!preventDuplicateEvent) {
    // then run the thing
    // but first put the lock in place
    preventDuplicateEvent = true
    setTimeout(() => {
      preventDuplicateEvent = false
    }, 10)
    return fct(event)
  } // else ignore it
}

/**
 * will process each incoming keydown event and try to match them to the list given in the shortcut attribute
 **/
export class ShortcutElement extends HTMLElement {
  connectedCallback () {
    console.log('hello', this)
    // when the element is created: add some listeners to the body
    // we'll take them out when it's all over
    this.listener = (evt) => {
      console.log('undedup evt -> ', evt, this.shortcuts)
      // dedup((event) => {
      const event = evt
      console.log("what we've got here is an event: ", event)
      this.shortcuts
        .filter(
          ({ baseKey, alt, shift, ctrl, meta }) =>
            deburr(event.key).toLowerCase() === baseKey.toLowerCase() &&
            (alt == null || alt === event.altKey) &&
            (shift == null || shift === event.shiftKey) &&
            (ctrl == null || ctrl === event.ctrlKey) &&
            (meta == null || meta === event.metaKey)
        ) // now we have all the shortcuts that match the current event
        .map(({ name }) => {
          event.preventDefault()
          event.stopPropagation()
          this.dispatchEvent(
            new CustomEvent('shortcut', {
              bubbles: false,
              detail: {
                name,
                event
              }
            })
          )
        })
      // }, evt)
    }
    document.body.addEventListener('keydown', this.listener, { capture: true })
  }

  disconnectedCallback () {
    document.body.removeEventListener('keydown', this.listener, {
      capture: true
    })
  }
}

customElements.define('shortcut-element', ShortcutElement)
