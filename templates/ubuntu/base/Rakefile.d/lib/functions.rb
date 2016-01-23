# Extract command arguments from ARGV.
#
# For example,
# you get '*' and ' ' characters in the following.
#   rake taskname ******* *** *****
#   rake taskname[rake_args] ****** *****
#   rake env=val taskname ****** *****
#
# @param  [Rake::Task] task the instance
# @return [String]
def extract_command_args(task)
  re = Regexp.new("^#{task.to_s}\\[?")

  (ARGV.size < 2) ?
      '' :
      ARGV.drop_while {|v| !(v.match(re)) }
          .drop(1)
          .join(' ')
end

# Load a ERB template file
#
# @param [String] filepath
# @param [Hash]   params used in the ERB
def load_template(filepath, params)
  src = File.read(filepath)
  Erubis::Eruby.new(src).evaluate(params)
end

# Write on a file with sudo privillege
#
# @param [String] filepath
# @param [String] data
# @param [String] temp_prefix
#                   the name of a temporary file
#                   which is made for preparation of actually writing
def sudo_write(filepath, data, temp_prefix='tempfile')
  temp = "#{temp_prefix}.~"

  File.write(temp, data)
  sh "sudo mv \"#{temp}\" #{filepath}"
end
