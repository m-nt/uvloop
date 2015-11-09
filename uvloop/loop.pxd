# cython: language_level=3


from . cimport uv

from libc.stdint cimport uint64_t


include "consts.pxi"


cdef class UVHandle
cdef class UVAsync(UVHandle)
cdef class UVTimer(UVHandle)
cdef class UVSignal(UVHandle)
cdef class UVIdle(UVHandle)


cdef class Loop:
    cdef:
        uv.uv_loop_t *loop

        bint _closed
        bint _debug
        bint _running
        bint _stopping

        long _thread_id

        object _ready
        Py_ssize_t _ready_len

        set _handles
        dict _polls
        dict _polls_gc

        UVAsync handler_async
        UVIdle handler_idle
        UVSignal handler_sigint
        UVSignal handler_sighup

        object _last_error

        cdef object __weakref__

        char _recv_buffer[UV_STREAM_RECV_BUF_SIZE]
        bint _recv_buffer_in_use


    cdef _run(self, uv.uv_run_mode)
    cdef _close(self)
    cdef _stop(self)
    cdef uint64_t _time(self)

    cdef _call_soon(self, object callback)
    cdef _call_later(self, uint64_t delay, object callback)

    cdef inline void __track_handle__(self, UVHandle handle)
    cdef inline void __untrack_handle__(self, UVHandle handle)

    cdef void _handle_uvcb_exception(self, object ex)

    cdef inline _check_closed(self)
    cdef inline _check_thread(self)

    cdef _getaddrinfo(self, str host, int port,
                      int family, int type,
                      int proto, int flags,
                      int unpack)

    # cdef _sock_recv(self, fut, registered, sock, n)
    # cdef _sock_sendall(self, fut, registered, sock, data)


cdef class Handle:
    cdef:
        object callback
        int cancelled
        int done
        object __weakref__

    cdef inline _run(self)
    cdef _cancel(self)


cdef class TimerHandle:
    cdef:
        object callback
        int closed
        UVTimer timer
        Loop loop
        object __weakref__

    cdef _cancel(self)


include "handle.pxd"
include "async_.pxd"
include "idle.pxd"
include "timer.pxd"
include "signal.pxd"
include "poll.pxd"

include "stream.pxd"
include "tcp.pxd"
