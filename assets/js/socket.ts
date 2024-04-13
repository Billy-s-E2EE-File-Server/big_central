import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {upload_file_metadata} from "./files"

let Hooks: any = {};
Hooks.UploadFileHook = {
    mounted() {
        this.el.addEventListener("change", (_e: any) => {
            upload_file_metadata(this);
        });
    }

};

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");

var liveSocket = new LiveSocket("/live", Socket, {
  //longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
});

export { liveSocket }
