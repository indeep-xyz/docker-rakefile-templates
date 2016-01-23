class ProjectManager
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def sh(str)
    Rake::sh make_command(str)
  end

  def exec(str)
    `#{make_command(str)}`
  end

  def make_command(str)
    "docker-compose -p=\"#{@name}\" #{str}"
  end
end