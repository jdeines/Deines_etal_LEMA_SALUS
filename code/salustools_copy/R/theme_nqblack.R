# From https://gist.github.com/jslefche/eff85ef06b4705e6efbc
# Modified  whites to #EEECE1 and black to #262626

theme_nqblack <- function(base_size = 12, base_family = "") {

  theme_grey(base_size = base_size, base_family = base_family) %+replace%

    theme(
      # Specify axis options
      axis.line = element_blank(),
      axis.text.x = element_text(size = base_size*0.8, color = "#EEECE1", lineheight = 0.9),
      axis.text.y = element_text(size = base_size*0.8, color = "#EEECE1", lineheight = 0.9),
      axis.ticks = element_line(color = "#EEECE1", size  =  0.2),
      axis.title.x = element_text(size = base_size, color = "#EEECE1", margin = margin(0, 10, 0, 0)),
      axis.title.y = element_text(size = base_size, color = "#EEECE1",
                                  angle = 90, margin = margin(0, 10, 0, 0)),
      axis.ticks.length = unit(0.3, "lines"),
      # Specify legend options
      legend.background = element_rect(color = NA, fill = "#262626"),
      legend.key = element_rect(color = "#EEECE1",  fill = "#262626"),
      legend.key.size = unit(1.2, "lines"),
      legend.key.height = NULL,
      legend.key.width = NULL,
      legend.text = element_text(size = base_size*0.8, color = "#EEECE1"),
      legend.title = element_text(size = base_size*0.8, face = "bold", hjust = 0, color = "#EEECE1"),
      legend.position = "right",
      legend.text.align = NULL,
      legend.title.align = NULL,
      legend.direction = "vertical",
      legend.box = NULL,
      # Specify panel options
      panel.background = element_rect(fill = "#262626", color  =  NA),
      panel.border = element_rect(fill = NA, color = "#EEECE1"),
      panel.grid.major = element_line(color = "grey35"),
      panel.grid.minor = element_line(color = "grey20"),
      panel.spacing = unit(0.5, "lines"),
      # Specify facetting options
      strip.background = element_rect(fill = "grey30", color = "grey10"),
      strip.text.x = element_text(size = base_size*0.8, color = "#EEECE1"),
      strip.text.y = element_text(size = base_size*0.8, color = "#EEECE1",angle = -90),
      # Specify plot options
      plot.background = element_rect(color = "#262626", fill = "#262626"),
      plot.title = element_text(size = base_size*1.2, color = "#EEECE1"),
      plot.margin = unit(rep(1, 4), "lines")

    )

}
