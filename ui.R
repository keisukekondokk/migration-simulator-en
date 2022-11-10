## (c) Keisuke Kondo
## Date (First Version): 2022-11-10
## Date (Latest Version): 2022-11-10
## 
## - global.R
## - server.R
## - ui.R
## 

#HEADER-------------------------------------------------------------------------
header <- dashboardHeader(
  title = "Migration Simulator",
  titleWidth = 300,
  disable = FALSE
)
#SIDEBAR------------------------------------------------------------------------
sidebar <- dashboardSidebar(
  width = 300,
  #++++++++++++++++++++++++++++++++++++++
  #CSS
  useShinyjs(),
  tags$head(
    # Include CSS
    includeCSS("styles.css")
  ),
  #++++++++++++++++++++++++++++++++++++++
  h2(span(style="border-bottom: solid 1px white;", "Simulation Setting")),
  #NOTE
  p("This Shiny App calculates the costs and benefits of interregional migration in Japan."),
  div(id="slider_inline",
    # Annual Nominal Income before Migration
    sliderInput(
      "preincome",
      "Annual Income Pre-Migration (unit: 10 thousand yen):",
      min = 100,
      max = 1500,
      value = 300,
      step = 10
    ),
    # Annual Nominal Income after Migration
    sliderInput(
      "postincome",
      "Annual Income Post-Migration (unit: 10 thousand yen):",
      min = 100,
      max = 1500,
      value = 300,
      step = 10
    ),
    # Migration Costs
    sliderInput(
      "subsidy",
      "Migration Subsidy (unit: 10 thousand yen):",
      min = 0,
      max = 1000,
      value = 60,
      step = 10
    ),
    # Relative Costs of Livings
    sliderInput(
      "costofliving",
      "Relative Cost of Living:",
      min = 0.1,
      max = 3,
      value = 0.8,
      step = 0.01
    ),
    # Migration Distance
    sliderInput(
      "distance",
      "Migration Distance (unit: km):",
      min = 0,
      max = 1000,
      value = 500,
      step = 10
    ),
    # Distance Decay Parameter
    sliderInput(
      "delta",
      "Distance Decay Parameter (see Model tab)",
      min = 0,
      max = 0.5,
      value = 0.186,
      step = 0.001
    ),
  ),
  # Simulation Button
  div(
    actionButton("buttonSimulation", span(icon("play-circle"), "Simulate"), class="btn btn-info"),
    p("Press the Simulate button after setting variables and parameters.")
  )
)
#BODY---------------------------------------------------------------------------
body <- dashboardBody(
  #++++++++++++++++++++++++++++++++++++++
  #CSS
  useShinyjs(),
  tags$head(
    # Include CSS
    includeCSS("styles.css")
  ),
  #++++++++++++++++++++++++++++++++++++++
  ####################################
  ## NAVBARPAGE
  ## - Visualize simulation
  ## - Model
  ## - Author
  ## - Terms of Use
  ## - Github
  ####################################
  navbarPage(
    span(style="font-weight:bold;color:white", "MENU"),
    id = "navbarpageMain",
    theme = shinytheme("yeti"),
    #++++++++++++++++++++++++++++++++++++++
    ####################################
    ## TABPANEL
    ## - Visualization
    ## - Model
    ## - Author
    ## - Terms of Use
    ## - Github
    ####################################
    tabPanel(
      "Migration Simulation", 
      icon = icon("chart-line"),
      div(
        style = "margin-left: -25px; margin-right: -25px;",
        #------------------------------------------------
        fluidRow(
          column(
            width = 12,
            div(
              style = "margin: 10px",
              h2(span(icon("chart-line"), "Migration Simulation")),
            ),
            div(
              style = "margin: 15px -5px -5px -5px;",
              column(
                width = 12,
                offset = 0,
                style="padding: 0px;",
                valueBoxOutput("vBox1", width = 4),
                valueBoxOutput("vBox2", width = 4),
                valueBoxOutput("vBox3", width = 4)
              ),
              column(
                width = 12,
                offset = 0,
                style="padding: 0px;",
                valueBoxOutput("vBox4", width = 6),
                valueBoxOutput("vBox5", width = 6)
              )
            )
          ),
          column(
            width = 12,
            div(
              style = "margin: 0px 10px 10px 10px;",
              box(
                width = NULL,
                solidHeader = FALSE,
                linePlotUI("linePlot")
              )
            )
          )
        )
      )
    ),
    #++++++++++++++++++++++++++++++++++++++
    tabPanel(
      "Model", 
      icon = icon("file-alt"),
      div(
        style="margin-left: -30px; margin-right: -30px;",
        #
        column(
          width = 12,
          box(
            width = NULL, 
            title = h2(span(icon("file-alt"), "Model")), 
            solidHeader = TRUE,
            #
            withMathJax(),
            #
            p("Publication Date: November 10, 2022", align="right"),
            #------------------------------------------------------------------
            h3(style="border-bottom: solid 1px black;", "Introduction"),
            p("This study provides a simple framework for ex ante evaluation of migration subsidy. The Japanese government initiated a migration subsidy program in April 2019 to promote urban-to-rural migration for the purpose of regional revitalization. Counterfactual simulations based on this framework provide scientific insight into the potential impact of migration subsidy, helping policymakers determine the optimal amount under the budget constraint."
            ),
            #------------------------------------------------------------------
            h3(style="border-bottom: solid 1px black;", "Discrete Choice Model of Interregional Migration"),
            p("The discrete choice model of interregional migration was constructed from the viewpoint of utility maximization. Suppose that a household residing in region \\(i\\) migrates into region \\(j\\) to live there for \\(T\\) periods. Region \\(j\\) may be equal to region \\(i\\), meaning that a household continuously resides in region \\(i\\)."),
            p("The ex ante evaluation framework proposed in this study formulates the payout period of interregional migration as investment behavior. The model assumes that a household invests in residing in region \\(j\\) paying the lump sum costs of migration at the timing of migration. The household gains a return in each period by residing in region \\(j\\) as migration benefits. The payout period of interregional migration is defined as how many periods are required until the household gains positive net migration benefits. It is considered that a household decides to migrate from region \\(i\\) to region \\(j\\) if the payout period is shorter than the planned residing period. The migration subsidy leads to an incentive of interregional migration by shortening the payout period. Therefore, the potential impact of migration subsidy is measured by the comparison of the payout period between cases with and without migration subsidy."),
            p("Based on the model, nominal migration benefits \\( \\mathrm{NMB} \\) and nominal migration costs \\( \\mathrm{NMC} \\) are calculated as follows:"),
            p("\\( \\mathrm{NMB} = T \\left( I_{j} - I_{i} \\dfrac{P_{j}}{P_{i}} \\right) + S_{j} \\)"),
            p("\\( \\mathrm{NMC} = ( D_{ij}^{\\delta} - D_{ii}^{\\delta} ) I_{i} \\dfrac{P_{j}}{P_{i}} \\)"),
            p("where \\( I_{j} \\) is the annual nominal income in region \\(j\\), \\( I_{i} \\) is the annual nominal income in region \\(i\\), \\( S_{j} \\) is the migration subsidy in region \\(j\\), \\( P_{j} / P_{i} \\) is the relative cost of living between region \\(j\\) and region \\(i\\), \\( D_{ij} \\) is the migration distance from region \\(i\\) to region \\(j\\), and \\( \\delta \\) is the distance decay parameter of migration costs."),
            p("The migration costs are expressed as \\( D_{ij}^{\\delta} \\). The migration costs for staying in region \\(i\\) is  \\( D_{ii}^{\\delta} = 1\\). This study employs a structural estimation to estimate the migration costs because these costs are not observable for researchers. The distance decay parameter \\( \\delta \\) is estimated from interregional migration flow data."),
            p("The payout period required \\(\\bar{T}\\) is derived from the condition \\( \\mathrm{NMB} = \\mathrm{NMC} \\). See Kondo (2019, 2022) for more details."),
            #------------------------------------------------------------------
            h3(style="border-bottom: solid 1px black;", "Estimates of Distance Decay Parameter"),
            p("Please refer to tables below to determine a distance decay parameter in the simulation setting."),
            # Estimation Results
            h4(style="text-decoration: underline;", "Estimation results from migration flows across all municipalities"),
            p("The tables present the distance decay parameters, which are estimated from the interregional migration data across all municipalities in Japan."),
            column(
              width = 12,
              tableOutput("tableDeltaAllMale")
            ),
            column(
              width = 12,
              tableOutput("tableDeltaAllFemale")
            ),
            # Estimation Results
            h4(style="text-decoration: underline;", "Estimation results from migration flows into 23 special wards of Tokyo"),
            p("The tables present the distance decay parameters, which are estimated from the data of migration into the 23 special wards of Tokyo."),
            column(
              width = 12,
              tableOutput("tableDeltaInMale")
            ),
            column(
              width = 12,
              tableOutput("tableDeltaInFemale")
            ),
            # Estimation Results
            h4(style="text-decoration: underline;", "Estimation results from migration flows out of 23 special wards of Tokyo"),
            p("The tables present the distance decay parameters, which are estimated from the data of migration out of the 23 special wards of Tokyo."),
            column(
              width = 12,
              tableOutput("tableDeltaOutMale")
            ),
            column(
              width = 12,
              tableOutput("tableDeltaOutFemale")
            ),
            #------------------------------------------------------------------
            h3(style="border-bottom: solid 1px black;", "References"),
            HTML("<ul>
                 <li>Kondo, Keisuke (2022) &quot;Ex Ante Policy Evaluatgion of Migration Subsidy: Evidence from Japan,&quot; in progress.</li>
                 <li>Kondo, Keisuke (2019) &quot;Monopolar Concentration in Tokyo and Promotion of Urban-to-Rural Migration,&quot; RIETI PDP No. 19-P-006 (Revised in November 2022) (in Japanese).<br/>
                 https://www.rieti.go.jp/en/publications/summary/19040007.html</li>
                 </ul>"
            ),
          )
        )
      )
    ),
    #++++++++++++++++++++++++++++++++++++++
    tabPanel(
      "Author", 
      icon = icon("user"),
      div(
        style="margin-left: -30px;margin-right: -30px;",
        column(
          width = 12,
          box(
            width = NULL, 
            title = h2(span(icon("user"), "Author")), 
            solidHeader = TRUE,
            h3("Keisuke Kondo"),
            p("I am a senior fellow of the Research Institute of Economy, Trade and Industry (RIETI) and an associate professor (cross appointment) at the Research Institute for Economics and Business Administration (RIEB), Kobe University in Japan."),
            h3("Contact"),
            p("Email: kondo-keisuke@rieti.go.jp"),
            p("URL: ", a(href = "https://keisukekondokk.github.io/", "https://keisukekondokk.github.io/", .noWS = "outside"), .noWS = c("after-begin", "before-end")),
            p("Address: METI Annex 11F, 1-3-1 Kasumigaseki, Chiyoda-ku, Tokyo, 100-8901, Japan"),
            a(href="https://www.rieti.go.jp/en/", img(src="logo_rieti.jpeg", width= "480" )),
            br(clear="right"),
            br(),
            p("The views expressed here are solely those of the author, and neither represent those of the organization to which the author belongs nor the Research Institute of Economy, Trade and Industry.")
          )
        )
      )
    ),
    #++++++++++++++++++++++++++++++++++++++
    tabPanel(
      "Terms of Use", 
      icon = icon("file-signature"),
      div(
        style="margin-left: -30px;margin-right: -30px;",
        column(
          width = 12,
          box(
            width = NULL, 
            title = h2(span(icon("file-signature"), "Terms of Use")), 
            solidHeader = TRUE,
            p("Users (hereinafter referred to as the User or Users depending on context) of the content on this web site (hereinafter referred to as the Content) are required to conform to the terms of use described herein (hereinafter referred to as the Terms of Use). Furthermore, use of the Content constitutes agreement by the User with the Terms of Use. The content of the Terms of Use is subject to change without prior notice."),
            h3("Copyright"),
            p("The copyright of the developed code belongs to Keisuke Kondo."),
            h3("Copyright of Third Parties"),
            p("Some of the Content may contain content provided by third parties. Users must not infringe copyright works of the third parties."),
            h3("License "),
            p("The developed code is released under the MIT License."),
            h3("Disclaimer"),
            HTML("<ul>
            <li>Keisuke Kondo makes the utmost effort to maintain, but nevertheless does not guarantee, the accuracy, completeness, integrity, usability, and recency of the Content.</li>
            <li>Keisuke Kondo and any organization to which Keisuke Kondo belongs hereby disclaim responsibility and liability for any loss or damage that may be incurred by Users as a result of using the Content. Keisuke Kondo and any organization to which Keisuke Kondo belongs are neither responsible nor liable for any loss or damage that a User of the Content may cause to any third party as a result of using the Content.</li>
            <li>The Content may be modified, moved or deleted without prior notice.</li>
            </ul>"),
            br(),
            br(),
            p("Release Date: November 10, 2022"),
            br()
          )
        )
      )
    ),
    #++++++++++++++++++++++++++++++++++++++
    tabPanel(
      "GitHub", 
      icon = icon("github"),
      fluidRow(
        #
        column(
          width = 12,
          box(
            width = NULL, 
            title = h2(span(icon("github"), "GitHub")), 
            solidHeader = TRUE,
            h3("View code"),
            p("The R code of the Shiny App is available on Github."),
            p("URL: ", a(href = "https://keisukekondokk.github.io/", "https://keisukekondokk.github.io/", .noWS = "outside"), .noWS = c("after-begin", "before-end")),
            p("URL: ", a(href = "https://github.com/keisukekondokk/migration-simulator-en", "https://github.com/keisukekondokk/migration-simulator-en", .noWS = "outside"), .noWS = c("after-begin", "before-end"))
          )
        )
      )
    )
  )
)
#DASHBOARD----------------------------------------------------------------------
dashboardPage(
  header,
  sidebar,
  body
)
