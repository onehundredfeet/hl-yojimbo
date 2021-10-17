#ifndef __BUFFER_POOL_H_
#define __BUFFER_POOL_H_
#pragma once
#include <vector>

class BufferPool {
    public:
    
    struct Buffer {
        enum State {
            BUFFER_UNINITIALIZED,
            BUFFER_ALLOCATED,
            BUFFER_DORMANT
        };

        Buffer() {
            state = BUFFER_UNINITIALIZED;
            _pool = nullptr;
        }
        Buffer( BufferPool *pool, void *data, int size) {
            this->data = data;
            this->realSize = size;
            this->requestedSize = size;
            this->state = BUFFER_ALLOCATED;
            _pool = pool;
        }

        void Return() {
            _pool->Return(*this);
            state = BUFFER_UNINITIALIZED;
        }
        void *data;
        int realSize;
        int requestedSize;
        State state;
        BufferPool *_pool;
    };


    std::vector<Buffer> _buffers;
    Buffer Rent(int size) {
        int closestIdx = -1;
        int closestSize = INT_MAX;

        for(auto i = 0; i < _buffers.size(); i++) {
            if (_buffers[i].realSize >= size) {
                if (_buffers[i].realSize < closestSize) {
                    closestSize = _buffers[i].realSize;
                    closestIdx = i;
                }
            }
        }
        if (closestIdx >=0) {
            auto x = _buffers.back();
            _buffers.pop_back();
            if (closestIdx != _buffers.size()) {
                auto y = _buffers[closestIdx];
                _buffers[closestIdx] = x;
                y.state = Buffer::BUFFER_ALLOCATED;
                y.requestedSize = size;
                return y;
            }
            x.state = Buffer::BUFFER_ALLOCATED;
            x.requestedSize = size;
            return x;
        } else {
            return Buffer( this, new char[size], size);
        }
    }

    void Return(Buffer b) {
        b.state = Buffer::BUFFER_DORMANT;
        _buffers.push_back(b);
    }
    
};

#endif