;;; openai-code-helper.el --- Ask OpenAI about selected code

;; Author: Assistant
;; Keywords: openai, ai, code
;; Version: 0.1

;;; Code:

(require 'json)
(require 'url)

(defvar openai-api-key ""
  "OpenRouter API key for authentication.")

(defun ask-openai-about-code ()
  "Send selected code with a question to OpenAI API."
  (interactive)
  (if (use-region-p)
      (let* ((selected-code (buffer-substring-no-properties (region-beginning) (region-end)))
             (question (read-string "Ask about code: "))
             (combined-prompt (format "Question: %s\n\nCode:\n%s" question selected-code))
             (url-request-method "POST")
             (url-request-extra-headers
              `(("Content-Type" . "application/json")
                ("Authorization" . ,(concat "Bearer " openai-api-key))))
             (url-request-data
              (json-encode
               `(("model" . "anthropic/claude-3.5-sonnet")
                 ("messages" . [(("role" . "user")
                               ("content" . ,combined-prompt))])
                 ("temperature" . 1)
                 ("top_p" . 1)
                 ("frequency_penalty" . 0)
                 ("presence_penalty" . 0)
                 ("repetition_penalty" . 1)
                 ("top_k" . 0))))
             (response-buffer (url-retrieve-synchronously
                             "https://openrouter.ai/api/v1/chat/completions")))
        (with-current-buffer response-buffer
          (goto-char url-http-end-of-headers)
          (let* ((json-object-type 'plist)
                 (response-data (json-read))
                 (response-text (plist-get (aref (plist-get response-data :choices) 0) :message)))
            (kill-buffer response-buffer)
            (with-current-buffer (get-buffer-create "*OpenAI Response*")
              (erase-buffer)
              (insert (plist-get response-text :content))
              (display-buffer (current-buffer))))))
    (message "No region selected")))

(defun openai-code-helper-setup ()
  "Setup key binding for ask-openai-about-code function."
  (global-set-key (kbd "C-k") 'ask-openai-about-code))

(provide 'openai-code-helper)

;;; openai-code-helper.el ends here
