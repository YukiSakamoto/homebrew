require "formula"

# Documentation: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
#
def check_command_existence(cmd_name)
	ret = `type #{cmd_name} 1>/dev/null 2>/dev/null`
	return $?.exitstatus == 0 ? true : false
end

class Ecell4 < Formula
  homepage ""
  url "https://github.com/ecell/ecell4.git"
  sha1 ""

  # depends_on "cmake" => :build
  #depends_on :x11 # if your formula requires any X11/XQuartz components
  depends_on "boost"
  depends_on "gsl"
  depends_on "pkg-config"
  depends_on "hdf5" => '--enable-cxx'

  option 'without-python', 'Do not install python wrappers'

  def install
	def waf_build_cppmodule(target)
		Dir.chdir(target) do
			system "../waf configure --prefix=#{prefix}"
			system "../waf build"
			system "../waf install"
		end
	end
	def waf_build_cython_module(target)
		Dir.chdir(target) do 
			system "../waf configure --prefix=#{prefix}"
			system "../waf build"
			system "../waf install"
		end
	end


	ecell4_modules = ['core', 'ode', 'gillespie', 'bd']
	ENV['LIBRARY_PATH'] = "#{prefix}/lib"
	ENV['CPATH'] = "#{prefix}/include"

	ecell4_modules.each do |modname|
		waf_build_cppmodule(modname)
		print "build #{modname} done\n"
	end


	unless build.include?('without-python')
		while check_command_existence('cython') == false
			print "Installing Cython\n"
			#ENV['PYTHONUSERBASE'] = "#{prefix}/bin"
			#ENV['PATH'] += ":#{prefix}/bin"
			`pip install --user cython`
		end
		cython_location = `which cython` + '/..'
		ENV['PATH'] += (':' + cython_location)
		ecell4_modules.each do |modname|
			waf_build_cython_module(modname + '_python')
			print "build #{modname}_python done\n"
		end
	end

  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test ecell`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
