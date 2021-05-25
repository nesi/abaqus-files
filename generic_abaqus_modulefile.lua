require 'io'
require 'os'
require 'lfs'


local version = myModuleVersion()

local ABAQUS = "/opt/nesi/share/ABAQUS"
local LICENSES = pathJoin(ABAQUS, 'Licenses')
local root = pathJoin(ABAQUS, version)

function file_readable(name)
   local f = io.open(name, "r")
   if f~=nil then io.close(f) return true else return false end
end

local license_file = nil
for fn in lfs.dir(LICENSES) do
   if fn:sub(-4) == ".lic" then
      local candidate_licence_file = pathJoin(LICENSES, fn)
      if file_readable(candidate_licence_file) then      
         license_file = candidate_licence_file
         break
      end
   end
end                                                                                       
                                                                                          
if license_file ~= nil then
   setenv('ABAQUSLM_LICENSE_FILE', '@' .. capture('/bin/cat "' .. license_file .. '" | /usr/bin/awk \'{print $2}\' | /usr/bin/tr -d "\n "'))
elseif mode() == "load" then
   LmodError("You do not appear to be a member of any group licensed to use ABAQUS")
end

conflict("ABAQUS")

prepend_path("PATH", pathJoin(ABAQUS, "Commands"))
prepend_path("CPATH", pathJoin(ABAQUS, "CAE/", version, "linux_a64/SMA/site"))
prepend_path("CPATH", pathJoin(root, "linux_a64/code/include"))

setenv("ABA_VER", version) --For use in custom_v6.env
setenv("MPI_ROOT", pathJoin(ABAQUS, "CAE", version, "linux_a64/code/bin/SMAExternal/pmpi"))
set_alias('abaqus', pathJoin(ABAQUS, 'Commands', 'abq' .. version))

whatis([[Finite Element Analysis software for modeling, visualization and best-in-class implicit and explicit dynamics FEA. - Homepage: http://www.simulia.com/products/abaqus_fea.html]])
