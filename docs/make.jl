using Documenter, Circo

makedocs(sitename = "Circo Documentation",
  pages = [
  "intro.md",
  "gettingstarted.md",
  "reference.md",
  "Design" => "design.md",
  "contribution.md"
])