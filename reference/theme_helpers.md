# Create a theme for a plotting or table package

Create a theme using background and foreground colors (`theme_colors_*`)
or using a **brand.yml** file (`theme_brand_*`).

## Usage

``` r
theme_colors_flextable(bg, fg)

theme_brand_flextable(brand_yml)

theme_colors_ggplot2(bg, fg)

theme_brand_ggplot2(brand_yml)

theme_colors_gt(bg, fg)

theme_brand_gt(brand_yml)

theme_colors_plotly(bg, fg)

theme_brand_plotly(brand_yml)

theme_colors_thematic(bg, fg)

theme_brand_thematic(brand_yml)
```

## Arguments

- bg:

  The background color

- fg:

  The foreground color

- brand_yml:

  The path to a brand.yml file

## Details

The use of the theme will depend on the package. Please see [light/dark
renderings
examples](https://examples.quarto.pub/lightdark-renderings-examples/ggplot2.html)
for examples using each supported package with dark mode,
`theme_brand_*`, and `renderings: [light, dark]`, or [theme helper
article](https://quarto-dev.github.io/quarto-r/articles/theme-helpers.html)
for examples using each package and `theme_colors_*` to specify the
background and foreground colors directly.
