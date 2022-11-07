# img-ms.lua
A pandoc filter to convert images (and pdfs) in your document to eps so that they work with the pdfroff backend

## minimal working example

test.md:
```md
![a single pdf image](./path/to/image.pdf)
![a png image](./path/to/image.png)
```
```sh
pandoc --lua-filter img-eps.lua -t ms -i test.md -o test.pdf
```

- for some reason pdfs cannot be directly included using pdfroff engine (works in groff 🤷)
- converting to svg first because image magic destroys the quality in pdf to eps conversions but is fine for svg to eps

- tries to save image to pandoc mediabag (not sure why images are saved in base directory as well, this will need fixing)
- set the image title to "fig:..." if caption is non-empty so that the images actually get captions (still not sure how to make them be numbered by pdfroff)
