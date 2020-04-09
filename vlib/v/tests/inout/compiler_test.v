import os
import term

fn test_all() {
	$if windows {
		return
	}
	mut total_errors := 0
	vexe := os.getenv('VEXE')
	vroot := os.dir(vexe)
	dir := os.join_path(vroot,'vlib/v/tests/inout')
	files := os.ls(dir) or {
		panic(err)
	}
	tests := files.filter(it.ends_with('.vv'))
	if tests.len == 0 {
		println('no compiler tests found')
		assert false
	}
	for test in tests {
		path := os.join_path(dir,test)
		print(test + ' ')
		program := path.replace('.vv', '.v')
		os.cp(path, program) or {
			panic(err)
		}
		x := os.exec('$vexe -o exe -cflags "-w" -cg $program') or {
			panic(err)
		}
		// os.rm(program)
		res := os.exec('./exe') or {
			println('nope')
			panic(err)
		}
		os.rm('./exe')
		// println('============')
		// println(res.output)
		// println('============')
		mut expected := os.read_file(program.replace('.v', '') + '.out') or {
			panic(err)
		}
		expected = expected.trim_space().trim('\n').replace('\r\n', '\n')
		found := res.output.trim_space().trim('\n').replace('\r\n', '\n')
		if expected != found {
			println(term.red('FAIL'))
			// println(x.output.limit(30))
			println('============')
			println('expected:')
			println(expected)
			println('============')
			println('found:')
			println(found)
			println('============\n')
			total_errors++
		}
		else {
			println(term.green('OK'))
		}
	}
	assert total_errors == 0
}
