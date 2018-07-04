# Pie Chart for all denbi cloud projects tuebingen and their corresponding 
# vCPU usage (reservation)

lbls <- c("elixir-demo",
          "Courage-PD", 
          "Sirius", 
          "jkrueger", 
          "MossGenomes", 
          "KNIME and OpenMS", 
          "earthsea", 
          "AltSplicing", 
          "PCTMQ", 
          "demo", 
          "DIFUTURE", 
          "Personal Health Train", 
          "Harvest Mouse Genetics")


slices_vcpu <- c(8, 122, 104, 28, 140, 11, 84, 106, 18, 136, 50, 188, 28)
sum_vcpu <- sum(slices_vcpu)

header_vcpu <- paste("vCPUs per Project (Total:", sum_vcpu, ") (03.07.2018)")
pie(slices_vcpu, labels = lbls, main= header_vcpu)

slices_ram <- c(16, 1018, 587, 240, 1200, 11, 718, 503, 34, 537, 98, 560, 240)
sum_ram <- sum(slices_ram)
header_ram <- paste("RAM per Project in GB (Total:", sum_ram, ") (03.07.2018)")
pie(slices_ram, labels = lbls, main=header_ram)

slices_storage <- c(147, 830, 250, 0, 1000, 0, 3900, 4900, 300, 1300, 100, 420, 1000)
sum_storage <- sum(slices_storage)
header_storage <- paste("Storage per Project in GB (Total:", sum_storage, ") (03.07.2018)")
pie(slices_storage, labels = lbls, main=header_storage)