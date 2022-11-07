--[[ minimal working example

test.md --> contains 2 images: ![a single pdf image](./path/to/image.pdf) and ![a png image](./path/to/image.png) on new lines
pandoc --lua-filter img-eps.lua -t ms -i test.md -o test.pdf

]] function Image(el) -- if image element
    local name = el.src:match("[^/]+$") -- get path (w/o extension)
    name = el.src:match("(.+)%..+$")
    local ext = el.src:match("[^.]+$")

    print('image extension is ' .. ext)
    if ext == 'eps' or ext == 'ps' then -- if it's not already a ps file
        print("no image conversion: image is eps")
    else
        print('needs converting') -- can be improved by checking if files have already been converted
        if ext == 'pdf' then
            -- for some reason pdfs cannot be directly included using pdfroff engine (works in groff 🤷)
            -- converting to svg first because image magic destroys the quality in pdf to eps conversions but is fine for svg to eps
            tmp_svg = name .. ".svg"
            print('converting image using pdf2svg')
            pandoc.pipe("pdf2svg", {el.src, tmp_svg}, "")
            -- finally convert to eps
            new_src = name .. ".eps" -- make new filename to send to convert
            print('converting image using rsvg')
            img_eps = pandoc.pipe("rsvg-convert",
                                  {"-f", "eps", "-o", new_src, tmp_svg}, "")
        else
            -- conversion is simpler for jpegs and pngs etc.
            print('converting using convert')
            new_src = name .. ".eps" -- make new filename to send to convert
            img_eps = pandoc.pipe("convert", {el.src, new_src}, "")
        end
        -- save image to pandoc mediabag (not sure why images are saved in base directory as well, this will need fixing)
        fname = pandoc.sha1(img_eps) .. '.eps'
        pandoc.mediabag.insert(fname, "application/postscript", img_eps)
    end

    -- set the image title to "fig:" if caption is non-empty so that the images actually get captions (still not sure how to make them be numbered by pdfroff)
    local cap = el.caption
    if cap ~= '' then title = #cap > 0 and "fig:" or "" end

    return pandoc.Image(cap, new_src, title)
end
