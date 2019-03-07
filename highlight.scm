(define (script-fu-highlight image drawable shadow-color shadow-opacity use-layer-opacity feather-border round-border)
  (if (= (car (gimp-selection-is-empty image)) FALSE)
      (let ((image-width (car (gimp-image-width image)))
            (image-height (car (gimp-image-height image)))
            (type (car (gimp-drawable-type-with-alpha drawable)))
            (save-selection (or (> feather-border 0) (> round-border 0))))
        (gimp-context-push)
        (gimp-context-set-defaults)
        (gimp-image-undo-group-start image)

        (let ((highlight-layer (car (gimp-layer-new image image-width image-height type "Highlight" (if (= use-layer-opacity TRUE) shadow-opacity 100) NORMAL-MODE))))
          (gimp-image-insert-layer image highlight-layer 0 -1)

          (let ((selection 0))
            (if save-selection
                (begin
                  (set! selection (car (gimp-selection-save image)))
                  (if (> round-border 0)
                      (script-fu-selection-rounded-rectangle image drawable round-border FALSE))
                  (if (> feather-border 0)
                      (gimp-selection-feather image feather-border))))

            (gimp-selection-invert image)

            (gimp-context-set-background shadow-color)
            (gimp-edit-bucket-fill highlight-layer BG-BUCKET-FILL NORMAL-MODE (if (= use-layer-opacity TRUE) 100 shadow-opacity) 0 FALSE 0 0)

            (if save-selection
                (begin
                  (gimp-image-select-item image CHANNEL-OP-REPLACE selection)
                  (gimp-image-remove-channel image selection))
                (gimp-selection-invert image))))

        (gimp-image-set-active-layer image drawable)
        (gimp-image-undo-group-end image)
        (gimp-displays-flush)
        (gimp-context-pop))))

(script-fu-register "script-fu-highlight"
  _"_Highlight Area..."
  _"Highlight an area of an image"
  "Olof-Joachim Frahm <olof@macrolet.net>"
  "Olof-Joachim Frahm"
  "2019"
  "RGB* GRAY*"
  SF-IMAGE      "Image"              0
  SF-DRAWABLE   "Drawable"           0
  SF-COLOR      _"Color"             "black"
  SF-ADJUSTMENT _"Opacity"           '(50 0 100 1 10 0 0)
  SF-TOGGLE     _"Use Layer Opacity" FALSE
  SF-ADJUSTMENT _"Feather Border"    '(0 0 50 1 5 0 0)
  SF-ADJUSTMENT _"Round Border (%)"    '(0 0 100 1 5 0 0))

(script-fu-menu-register "script-fu-highlight"
                         "<Image>/Filters/Light and Shadow/Shadow")
